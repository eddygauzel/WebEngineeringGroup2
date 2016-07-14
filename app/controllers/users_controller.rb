class UsersController < ApplicationController

  def anmelden
    user = User.find_by(loginName: params[:login])
    if user.nil?
      #return  status 400
      head 400
    else
      render json: user.to_json(only: %w(salt_masterkey privatekey_user_enc pubkey_user))

    end
  end

  def create
# erstellen
    if User.find_by(loginName: params[:login]).nil?
      user = User.new(loginName: params[:login] , salt_masterkey: params[:salt_masterkey], pubkey_user: params[:pubkey_user], privatekey_user_enc: params[:privatekey_user_enc])
      if user.save
        #render json: user.to_json
        head 200

      else
        #fehler beim anlegen
        head 400
      end
    else
      #return errorCode
      head 400
    end

  end

  def pubkey
    user = User.find_by(loginName: params[:login])
    if user.nil?
      head 404
    else
      render json: user.to_json(only: %w(pubkey_user))
    end
  end

  def delete
    begin
      pubkey = User.find_by(loginName: params[:login]).pubkey_user
      pb = OpenSSL::PKey::RSA.new(pubkey)
      sha_ds = pb.public_decrypt(params[:sig_service])
      # sha Hash Wert (sha-256 über Identität und TS)
      sha256 = Digest::SHA256.new
      #Identität
      ha256.update params[:login]
      #TS
      sha256.update params[:timestamp].to_i
      puts sha256.hexdigestx
      if sha256 != sha_ds
        head 404
      else
        #Zeitstempel Prüfen
        timenow = Time.zone.now().to_i
        timeMessage =params[:timestamp].to_i
        if (timenow-timeMessage)<=300
              user = User.find_by(loginName: params[:login])
              user.destroy
        else
          head 406
        end
      end
    rescue
      head 404
    end
  end
end

