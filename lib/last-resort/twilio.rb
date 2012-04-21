require 'twilio-ruby'

# Sandbox code
ACCOUNT_SID = ""
AUTH_TOKEN = ""
FROM_NUMBER = ""
HOST = ""

module LastResort

	class Contact
		attr_accessor :name, :number

		def initialize(name = "", number = "")
			@name = name
			@number = number
		end
	end

	class ExceptionSession

		# Array of strings representing numbers
		attr_accessor :contacts, :client, :call, :index, :description, :handled

		def initialize(contacts = [], description = "A general exception has occurred")
			@contacts = contacts
			@description = description
			@client = Twilio::REST::Client.new ACCOUNT_SID, AUTH_TOKEN
			@index = -1
			@handled = false
		end

	    # Return false if call was not made
		def call_next
			@index += 1

			return false if @handled || @index >= @contacts.size

			# Make the call
			@call = @client.account.calls.create(
			  :from => FROM_NUMBER,
			  :to => @contacts[@index].number,
			  :url => "http://#{HOST}/twilio/call",
			  :status_callback => "http://#{HOST}/twilio/status_callback"
			)

			return true
		end

		# Called when someone in the queue has handled this
		def end
			@handled = true
		end

		# Begin the notification cycle
		def notify
			self.call_next
		end

		# Name of the latest callee (latest call)
		def callee_name
			@contacts[@index].name
		end

		# Number of latest callee (latest call)
		def callee_number
			@contacts[@index].number
		end
	end
end