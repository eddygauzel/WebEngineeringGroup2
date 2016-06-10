class MessagesController < ApplicationController

  def send

    pubkey = User.find_by(loginName: params[:recipient]).pubkey_user

    pb = OpenSSL::PKey::RSA.new(pubkey)
    logger.info(pb)
    begin
      sha_ds = pb.public_decrypt(params[:sig_service])
      logger.info(pb)

      # sha Hash wert sha-256 über IU TS und Empf.
      sha256 = Digest::SHA256.new
      #IU
      sha256.update params[:recipient]
      sha256.update params[:Cipher]
      sha256.update params[:iv]
      sha256.update params[:key_recipient_enc]
      sha256.update params[:sig_recipient]

      #TS
      sha256.update params[:timestamp]
      #empf
      sha256.update params[:login]
      puts sha256.hexdigest
      logger.info(sha256)

      if sha256 != sha_ds
        head 404
      else
        timenow = Time.zone.now()
        timeMessage =params[:timestamp]

        if (timnow-timeMessage)<=300
          message = new Message(
                            sender: params[:recipient],
                            content_enc: params[:Cipher],
                            iv: params[:iv],
                            key_recipient_enc: params[:key_recipient_enc],
                            sig_recipient: params[:sig_recipient],
                            recipient: params[:login])
          message.save
          head 200
        else
          head 406
        end

      end
    rescue
      head 404
    end






  end


  def getMessage

    ds = params[:sig_service]
    pubkey = User.find_by(loginName: params[:login]).pubkey_user


    pb = OpenSSL::PKey::RSA.new(pubkey)
    begin
      pb.public_decrypt(params[:sig_service])



    rescue
      head 404
    end


    timenow = Time.zone.now()
    timeMessage =params[:timestamp]

    if (timnow-timeMessage)<=300

      messages = Message.find_by(recipient: params[:login])
      if messages.nil?
        head 506
      else

      render json: messages.to_json(only: %w(sender cipher iv key_recipient_enc sig_recipient ))
    end
    else
      head 406
    end


  end
end
