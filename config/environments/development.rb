require 'letter_opener'

configure :development do
  set :delivery_method, LetterOpener::DeliveryMethod
end
