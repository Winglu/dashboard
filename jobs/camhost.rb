# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'rubygems'
require 'net/ssh'
require 'net/telnet'
#nile only
DB = "172.19.128.84"
AP = "172.19.128.80"


@camData = ""
@spinData = ""
@cosmosData = ""
def getCamStatus
  Net::SSH.start(DB, 'delorenzoc', :keys => ['./delorenzoc-ssh2-rsa-1024.pem']) do |ssh|
    @counter =0;
    #zn 'admin';d ##class(Admin.Connectors.Control).Status('CAM')
    @adminCounter =0;
    ssh.exec! "csession prod"  do |channel, stream, data|
      #puts @counter+=1
      if @adminCounter==1
        @camData = data
      elsif @adminCounter ==2
        @spinData = data
      elsif @adminCounter ==3
        @cosmosData = data
        channel.close
      end
      if data.include?"USER"
        channel.send_data("zn \"admin\"\n")
      elsif data.include?"ADMIN"
        @adminCounter+=1
        if @adminCounter == 1
          channel.send_data("d ##class(Admin.Connectors.Control).Status(\"CAM\")\n")
        elsif @adminCounter == 2
          channel.send_data("d ##class(Admin.Connectors.Control).Status(\"SPIN\")\n")
        elsif @adminCounter == 3
          channel.send_data("d ##class(Admin.Connectors.Control).Status(\"COSMOS\")\n")
        end
      end
    end
    ssh.close
  end
end

SCHEDULER.every '1m', :first_in => 0 do |job|
  #
  @camStatus = Hash.new
  getCamStatus
  if @camData.include?"Missing"
    @camStatus["cam"] = "Missing"
  elsif @camData.include?"Trouble"
    @camStatus["cam"] = "Trouble"
  else
    @camStatus["cam"] = "Running"
  end

  if @spinData.include?"Missing"
    @camStatus["spin"] = "Missing"
  elsif @spinData.include?"Trouble"
    @camStatus["spin"] = "Trouble"
  else
    @camStatus["spin"] = "Running"
  end

  if @cosmosData.include?"Missing"
    @camStatus["cosmos"] = "Missing"
  elsif @cosmosData.include?"Trouble"
    @camStatus["cosmos"] = "Trouble"
  else
    @camStatus["cosmos"] = "Running"
  end
  @camList = Hash.new
  @camList["db"] ={cam:"CAM: "+@camStatus["cam"],spin:"SPIN: "+@camStatus["spin"],cosmos:"COSMOS: "+@camStatus["cosmos"]}
  send_event('nile_camhost', { cam_host_status: @camList.values})
  puts @camList.values
end