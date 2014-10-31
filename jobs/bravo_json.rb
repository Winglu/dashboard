require 'net/http'
require 'rubygems'
require 'json'
require 'uri'
require 'openssl'

@json
@file = './get-info.json'

SCHEDULER.every '10m', :first_in => 0 do |job|
  File.open(@file,'rb') do |f|
    req = Net::HTTP::Post.new('/bravo-info')
    req['Content-Type'] = 'application/json'
    req['Transfer-Encoding'] = 'chunked'

    req.body_stream = f
    res = Net::HTTP.new('10.26.160.53',31000).start { |http| http.request (req) }
    @json = res.body;
  end
  @result = JSON.parse(@json)
  puts @result
  #puts  @json
  send_event('totalSportBets', { title:"Total Sport Bets Sold",current:(@result["totalFixedOddsBetsSold"]).to_i})
  send_event('totalNormalBets', { title:"Total Bets Sold",current:(@result["totalParimutuelBetsSold"]).to_i})
  send_event('versionTerminals',{versionTitle:"Bravo Version",current:@result["bravoVersion"],terminalTitle:"Number of Terminals",numOfTerminal:(@result["activeTerminals"]).to_i})
  send_event('others',{xbStatus:"XB-Link: "+(@result["xbLinkStatus"]).to_s,ms:"Role: "+(@result["hostRole"]).to_s,sd:"Mode: "+(@result["hostMode"]).to_s})
end
