require 'mbox'
require 'csv'
require 'pry'

def column_names
  [ 'Date', 'Shopper Id', 'Product', 'Quantity', 'Price', 'Subtotal',
    'Shipping', 'Tax', 'TOTAL', 'Inv Name', 'Inv Company', 'Inv Address',
    'Inv City', 'Inv State', 'Inv Pst Code', 'Inv Country', 'Tel', 'Fax',
    'Email' ]
end

def parse(body)
  relevant_info = []
  content = body.split("\r\n").reject(&:empty?)
  content.each_with_index do |line, i|
    first_word = line.split(" ").first
    case first_word
    when 'Date'
      relevant_info << line[14..-1]
    when 'Product'
      line = content[i+1]
      product, quantity, price = line.split(":").map(&:strip)
      relevant_info << product
      relevant_info << quantity
      relevant_info << price
    else
      next unless (column_names + ['Shopper', 'Inv']).include? first_word
      relevant_info << line.split(":").map(&:strip)[1..-1]
    end
  end
  relevant_info
end

def filter(email)
  body = email.content.first.to_s
  parse body
end

def populate_csv
  Mbox.open('~/Downloads/Orders.mbox').each_with_index do |email, i|
    row = filter email
    CSV.open('tmp/test.csv', 'a+') do |csv|
      csv << row
    end
  end
end

def seed_table_headers
  CSV.open('tmp/test.csv', 'a+') { |csv| csv << column_names }
end

def main
  seed_table_headers
  populate_csv
end

main
