# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
=begin 
require 'net/ssh' 
require 'net/telnet'
require 'json'

USER = 'testing' 
PASS = 'testing' 
counter = 0
bravoServer = Hash.new
bravoServer['soyou'] = "10.26.160.51"
bravoServer['think'] = "10.26.160.52"
bravoServer['lets'] = "10.26.160.53"
bravoServer['elope'] = "10.26.160.54"

apps = Array.new

#apps.push("dev")
#apps.push("prdn")
#apps.push("prdv")
#apps.push("sitn")
#apps.push("sitv")
#apps.push("tstd")
apps.push("tste")
apps.push("tstf")
apps.push("tstg")
#apps.push("tsth")
#apps.push("tstn")
#apps.push("tstv")


@appOldStatus = Array.new; 
def fetchData(serverIP,appName)
  @counter = 0
  begin
    @status = ""
    Net::SSH.start( serverIP, USER, :password => PASS ) do|ssh| 
        
        sshCMD = "pipe set termi/devic=vt200/width=80/page=24 sys$output ; context bravo #{appName} ; define/user tt sys$output: ;inf flogga"
        #puts sshCMD
        ssh.exec sshCMD  do |channel, stream, data|
              @counter+=1
              if data.include?"nonexistent"
                @status = "dead"
                #puts @status
              else
                #puts data
              end
              if @counter > 10
                ssh.shutdown!
              end
  
        end
    end
  rescue IOError => e
      @status = "alive"
      #puts @status
  end
  return @status
end

class FadeOutApp
  def setApp(app)
    @app =app
  end
  def setServer(server)
    @server = server
  end
  def getApp
    return @app
  end
  def getServer
    return @server
  end
end


class BravoStatus
  def setApp(app)
    @app = app
  end
  def setServer(serverName)
    @server = serverName
  end
  def setStatus(status)
    @status = status
  end
  def getStatus
    return @status
  end
  def getApp
    return @app
  end
  def getServer
    return @server
  end
  def showStatus
    return "#{@app} on #{@server} is #{@status} !"
  end
end


SCHEDULER.every '60s', :first_in => 0 ,allow_overlapping: false do |job|
  #puts Dir.pwd;
  @filename = "config.txt"
  @txt = File.open(@filename)
  #@fadeOutAppList = null
  @fadeOutAppList = Array.new
  @txt.each_line do |line|
    if line.length!=0
      @fadeApp = FadeOutApp.new
      @fadeApp.setServer line.split(",")[0]
      @fadeApp.setApp(line.split(",")[1])
      @fadeOutAppList.push(@fadeApp)
    end
  end
  
  @appStatus = Array.new
  
  
  bravoServer.each_with_index do|(key,value), index|
      puts key+","+value
      apps.each do |app|
        #fetch data
        #puts app
        @statu = BravoStatus.new
        @statu.setServer(key)
        @statu.setApp(app)
        @result = fetchData value,app
        #puts @result
        @statu.setStatus(@result)
        @appStatus.push(@statu)
      end
  
   end
    
   
  if @appOldStatus.size==0
    #put new result to
     @appStatus.each do |status| 
       @appOldStatus.push(status)
     end
  end
  
  @flag = false;
  @appStatus.each do |status|
      @fadeOutAppList.each do |fadeApp| 
        if status.getServer.casecmp(fadeApp.getServer.strip)==0
          if status.getApp.casecmp(fadeApp.getApp.strip)==0
            @flag=true;
            break
          end
        else
          
        end
      end
      if @flag == true
        #puts status.getApp+","+status.getServer
        send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:status.getApp,moreinfo:'fade',server:status.getServer,text:status.getStatus})
        @flag = false;
      else
        send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:status.getApp,moreinfo:'',server:status.getServer,text:status.getStatus})
      end
  end
  
end
=end