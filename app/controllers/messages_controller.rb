class MessagesController < ApplicationController

  def send

    timenow = Time.zone.now()
    timeMessage =params[:timestamp]

    pubkey = User.find_by(loginName: params[:recipient]).pubkey_user
    pb = OpenSSL::PKey::RSA.new(pubkey)
    begin
      pb.public_decrypt(params[:sig_service])

    rescue
      head 404
    end

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


  def getMessage
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
