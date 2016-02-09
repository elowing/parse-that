require 'mbox'
require 'csv'

def column_names
  [ 'Date', 'Shopper Id', 'Product', 'Quantity', 'Price', 'Subtotal',
    'Shipping', 'Tax', 'TOTAL', 'Inv Name', 'Inv Company', 'Inv Address',
    'Inv City', 'Inv State', 'Inv Pst Code', 'Inv Country', 'Tel', 'Fax',
    'Email' ]
end

def process_date_of(line)
  @rows[0] << line[14..-1]
end

def pull_product_details_for(body, i, row)
  product, quantity, price = body[i].split(":").map(&:strip)
  row << product
  row << quantity
  row << price
  i += 1
end

def process_line_products_with(body, i)
  new_index = pull_product_details_for body, i, @rows[0]
  extra_product_num = 0
  until body[new_index].split(" ").first == "Voucher"
    extra_product_num += 1
    @rows[extra_product_num] = ['','']
    new_index = pull_product_details_for body, new_index, @rows[extra_product_num]
  end
end

def column_name_for(line)
  line.split(" ").first
end

def we_care_about?(column_name)
  (column_names + ['Shopper', 'Inv']).include? column_name
end

def relevant_details_of(line)
  line.split(":").map(&:strip)[1..-1].first
end

def extract_info_from(current_line, index, content)
  column_name = column_name_for current_line

  case column_name
  when 'Date'
    process_date_of current_line
  when 'Product'
    process_line_products_with content, index+1
  else
    return unless we_care_about? column_name
    @rows[0] << relevant_details_of(current_line)
  end
end

def strip(body)
  body.split("\r\n").reject(&:empty?)
end

def parse(content)
  body = strip content
  body.each_with_index do |line, i|
    extract_info_from line, i, body
  end
end

def get_content_from(email)
  email.content.first.to_s
end

def populate_csv
  Mbox.open('~/Downloads/Orders.mbox').each_with_index do |email, i|
    @rows = [[]]
    content = get_content_from email
    parse content
    CSV.open('tmp/test.csv', 'a+') do |csv|
      @rows.each { |row| csv << row }
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
