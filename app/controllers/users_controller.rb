class UsersController < ApplicationController

  def anmelden
    @user = User.find_by(loginName: params[:login])
    if @user.nil?
      #return  status 400
      head 400
    else
      render json: @user.to_json(only: %w(salt_masterkey privatekey_user_enc pubkey_user))

    end
  end

  def create

    if User.find_by(loginName: params[:login]).nil?
      @user = User.new(loginName: params[:login] , salt_masterkey: params[:salt_masterkey], pubkey_user: params[:pubkey_user], privatekey_user_enc: params[:privkey_user_enc])
      if @user.save
        #render json: @user.to_json
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
    @user = User.find_by(loginName: params[:login])
    if @user.nil?
      head 404
    else
      render json: @user.to_json(only: %w(pubkey_user))
    end
  end

  def delete
    timenow = Time.zone.now()
    timeMessage =params[:timestamp]

    pubkey = User.find_by(loginName: params[:login]).pubkey_user
    pb = OpenSSL::PKey::RSA.new(pubkey)
    begin
      pb.public_decrypt(params[:sig_service])

    rescue
      head 404
    end
    if (timnow-timeMessage)<=300

      user = User.find_by(loginName: params[:login])
      user.destroy


    end


  end

  def getMessage

    #authentifizieren
    begin

      sha_ds = pb.public_decrypt(params[:sig_service])

      # sha Hash Wert (sha-256 über Identität und TS)
      sha256 = Digest::SHA256.new
      #Identität
      ha256.update params[:login]
      #TS
      sha256.update params[:timestamp]

      puts sha256.hexdigest


      if sha256 != sha_ds
        head 404
      else
        #Zeitstempel Prüfen
        timenow = Time.zone.now()
        timeMessage =params[:timestamp]
        if (timnow-timeMessage)<=300
          mess = messages.find_by(recipient: params[:login])
          if mess.nil?
            head 506
          else
            render json: mess.to_json(only: %w(sender cipher iv key_recipient_enc sig_recipient ))

          end


        else
          head 406
        end

      end
    end
  rescue
    head 404
  end




end

