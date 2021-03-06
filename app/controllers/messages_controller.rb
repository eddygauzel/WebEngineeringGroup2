class MessagesController < ApplicationController

  def getmessage
    #authentifizieren
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
    rescue
      head 404
    end
  end

  def send_message
    begin
      pubkey = User.find_by(loginName: params[:recipient]).pubkey_user
      pb = OpenSSL::PKey::RSA.new(pubkey)
      sha_ds = pb.public_decrypt(params[:sig_service])
      # sha Hash Wert (sha-256 über IU, TS, und Empf.)
      sha256 = Digest::SHA256.new
      #IU
      sha256.update params[:recipient]
      sha256.update params[:Cipher]
      sha256.update params[:iv]
      sha256.update params[:key_recipient_enc]
      sha256.update params[:sig_recipient]
      #TS
      sha256.update params[:timestamp].to_i
      #empf
      sha256.update params[:login]
      puts sha256.hexdigest

      if sha256 != sha_ds
        head 404
      else
        timenow = Time.zone.now().to_i
        timeMessage =params[:timestamp].to_i
        if (timenow-timeMessage)<=300
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

end

