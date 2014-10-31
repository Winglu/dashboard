# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/ssh'
require 'net/telnet'
require 'json'


bravoServer = Hash.new
#pre server
HOST = '10.2.28.52' #brew
#bravoServer['arwon'] = "10.2.28.51"
#bravoServer['brew'] = "10.2.28.52"
#bravoServer['streak'] = "10.2.28.53"
#bravoServer['daacha'] = "10.2.28.54"

#pre app name
#arwonApp = Array.new
#arwonApp.push("prdv")

#brewApp = Array.new
#brewApp.push("prdv")

#streakApp = Array.new
#streakApp.push("prdn")

#daachaApp = Array.new
#daachaApp.push("prdn")



@betString = Array.new
@transcationStr = Array.new




@appOldStatus = Array.new;


@flag = true;
def fetchTrackSideData(serverIP,appName)
  #@cmd = "pipe set termi/devic=vt200/width=80/page=24 sys$output ; context bravo #{appName} ; define/user tt sys$output: ;inf flogga"
  begin
    Net::SSH.start( serverIP, USER, :password => PASS ) do|ssh|

      @time = Time.now.strftime("%H:%M")

      @cmd = "pipe set termi/devic=vt200/width=80/page=24 sys$output ; context bravo prdv ; @trackside.com;"
      ssh.exec @cmd  do |channel, stream, data|
        @betString.push data
        #puts data
          if data.include? "not in range"
            channel.close
            ssh.shutdown!
          elsif data.include?"error"
            channel.close
            ssh.shutdown!
          end
      end
      ssh.close
      end
  rescue IOError => e
    @flag = false
    #puts @status

  end







  if @flag
    Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
      @time = Time.now.strftime("%H:%M")
      @cmd = "pipe set termi/devic=vt200/width=80/page=24 sys$output ; context bravo prdv ; @itpquery.com;"
      ssh.exec @cmd  do |channel, stream, data|
        @transcationStr.push data
        #puts data
      end

      ssh.close;

    end

  end


end


SCHEDULER.every '100000s', :first_in => 0 do |job|
  #send_event('widget_id', { })
  #fetchTrackSideData "10.2.28.52","brew"
  #puts "bet"
  @isNotWorking = false
  @errorInf
  if @betString.empty?
	@isNotWorking = true
  else
	  @betString.each do |str|
		if str.include? "stack dump"
		  @errorInf = "software not startup"
		  @isNotWorking = true
		  break
		elsif str.include?"range"
		  @errorInf = "Configuration error."
		  @isNotWorking = true
		elsif str.include?"error"
		  @errorInf = "software not startup"
		  @isNotWorking = true
		end
	  end
   end
  @betString = Array.new;
  #puts "result"
  if !@isNotWorking
    @transcationStr.each do |str|
      if str.include?"tsl"
        @errorInf = "Failed."
        #puts str
        break
      else
        @errorInf = "Success"
        #put str
      end
    end
    @transcationStr = Array.new;
  else
    @errorInf = "Configuration error."
  end
  puts @errorInf
  send_event("nile_trackside_inf",{server:"Brew:PRDN",service:"Trackside",result:@errorInf})
  send_event("nile_spectrum",{server:"Brew:PRDN",service:"Spectrum",result:@errorInf})
  send_event("trackside_inf",{server:"PRDN",service:"Trackside",result:@errorInf})
  #send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:"vic slave",moreinfo:'',server:status.getApp+" "+status.getServer,text:status.getStatus})

end
