class UsersController < ApplicationController

  def anmelden
    user = User.find_by(loginName: params[:login])
    if user.nil?
      #return  status 400
      head 400
    else
      render json: @user.to_json(only: %w(salt_masterkey privatekey_user_enc pubkey_user))

    end
  end

  def create
# erstellen
    if User.find_by(loginName: params[:login]).nil?
      @user = User.new(loginName: params[:login] , salt_masterkey: params[:salt_masterkey], pubkey_user: params[:pubkey_user], privatekey_user_enc: params[:privatekey_user_enc])
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




end

