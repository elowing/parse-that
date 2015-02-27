require 'mbox'
require 'pry'

def sift(body)
  chunks = body.split "\r\n\r\n"
  invoiced_to = chunks[3]
  email = chunks[4]
  delivered_to = chunks[5]
  [invoiced_to, email, delivered_to]
end

def parse_mbox_file(mail)
  body = mail.content.first.to_s
  filtered_array = sift body
  return filtered_array
end

Mbox.open('~/Downloads/Orders.mbox').each do |mail|
  relevant_info = parse_mbox_file mail
  File.open('tmp/test', 'w') do |f|
    f.write relevant_info
  end
end
