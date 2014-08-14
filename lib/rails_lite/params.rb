require 'uri'

class Params
  # use initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @permitted_params = []
    @req = req
    
    if @req.query_string
      rqs_params = parse_www_encoded_form(@req.query_string)
    else
      rqs_params = {}
    end
    
    if @req.body
      rqb_params = parse_www_encoded_form(@req.body)
    else
      rqb_params = {}
    end
    
    @params = route_params.merge(rqs_params).merge(rqb_params)
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    keys.each { |key| @permitted_params << key }
  end

  def require(key)
    raise AttributeNotFoundError unless @params.has_key?(key)
  end

  def permitted?(key)
    @permitted_params.include?(key)
  end

  def to_s
    @params.to_json
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    parse_params = {}
    decoded = URI.decode_www_form(www_encoded_form)
    decoded.each do |pair|
      keys = pair.first
      value = pair.last
      keys = parse_key(keys)
      current_hash = parse_params
      keys.each_with_index do |key, index|
        if index == keys.length - 1
          current_hash[key] = value
        else
          current_hash[key] ||= {}
          current_hash = current_hash[key]
        end
      end
    end
    parse_params
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end