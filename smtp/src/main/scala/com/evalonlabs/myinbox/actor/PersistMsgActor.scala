package com.evalonlabs.myinbox.actor

import akka.actor.Actor
import javax.mail.internet.MimeMessage
import com.typesafe.scalalogging.slf4j.Logging
import java.util.Date
import com.evalonlabs.myinbox.util.{Crypto, UUID, Mail, Inbox}
import scala.language.postfixOps
import com.evalonlabs.myinbox.model.Message
import com.evalonlabs.myinbox.b2b.Sender

class PersistMsgActor extends Actor with Logging {

	def receive = {

		case message: Message[MimeMessage] => {
			val cleanMessage = Mail.filterMultiparts(message.body)
			val compressed = Mail.compress(cleanMessage)
      val sentDate = Option(message.body.getSentDate).getOrElse(new Date())
      val messageID = UUID.get()
      val uKey = Crypto.md5(message.to)

			try {
        Inbox.add(message.from, message.to, message.subject, compressed, sentDate)
        Inbox.index(message.from, message.to, message.subject, cleanMessage, sentDate)
        Sender.index(message.from, message.inet)
        SmtpAkkaSystem.userPrefsActor ! message
        // TODO - notify next services
			}
      catch {
				case e: Exception =>
          logger error "Exception saving message at " + new Date().getTime
          // TODO Dead letter channel
      }
		}

		case x => logger error "Unknown message: " + x.toString
	}

}