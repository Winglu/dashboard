
require 'net/ssh' 
require 'net/telnet'
require 'json'

USER = 'testing' 
PASS = 'testing' 

bravoDevServer = Hash.new
bravoDevServer['soyou'] = "10.26.160.51"
bravoDevServer['think'] = "10.26.160.52"
bravoDevServer['lets'] = "10.26.160.53"
bravoDevServer['elope'] = "10.26.160.54"


devApp = Array.new

devApp.push("tste")
devApp.push("tstf")
devApp.push("tstg")


arwonApp = Array.new
arwonApp.push("prdv")

brewApp = Array.new
brewApp.push("prdv")

streakApp = Array.new
streakApp.push("prdn")

daachaApp = Array.new
daachaApp.push("prdn")



#might be used to track up and down time
@appOldStatus = Array.new;

#fetch status by bravo server and application name
def fetchData(serverIP,appName)
  @counter = 0
  @status = "dead"
  begin
    @status = ""
    #puts serverIP
    Net::SSH.start(serverIP, USER, :password => PASS ) do|ssh|

      sshCMD = "pipe set termi/devic=vt200/width=80/page=24 sys$output ; context bravo #{appName} ; define/user tt sys$output: ;inf flogga"
      #puts sshCMD
      ssh.exec sshCMD  do |channel, stream, data|
        #puts data
        if data.include?"nonexistent"
          @status = "dead"
          ssh.shutdown!
          #puts @status
        end
        if data.include?"State"
          @status = "alive"
          ssh.shutdown!
        end
      end
    end
  rescue IOError => e
    #puts e
    return @status
  end
end

#data structure to store applications need to be fade out
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

#data structure to store bravo status
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

def sendProjectEnvironment(e,p)
  @str=""
  p.each_with_index do |v,index|
    if index!=0
      @str+=v+" "
    end
  end
  puts e
  puts @str
  send_event(e.strip,{title:e.strip,text:@str})
end

# scheduled works
SCHEDULER.every '15s',allow_overlapping:false  do |job|
  #puts Dir.pwd;
  @sendTitle = Array.new
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
      send_event("bravo_app_status_#{@fadeApp.getServer}_#{@fadeApp.getApp}",{title:"",moreinfo:'fade',server:@fadeApp.getApp+" "+@fadeApp.getServer,text:""})
    end
  end

  @envArray = Array.new;
  @envArray.push "congo"
  @envArray.push "ganges"
  @envArray.push "mekong"
  @envArray.push "thames"
  @envArray.push "danube"
  @envArray.push "zambeze"
  @envArray.push "murray"
  @envArray.push "yarra"
  @envArray.push "nile"
  @envArray.push "tste"
  @envArray.push "tstf"
  @envArray.push "tstg"


  #send_event("congo",{title:"congo",text:""})
  #send_event("ganges",{title:"ganges",text:""})
  #send_event("mekong",{title:"mekong",text:""})
  #send_event("thames",{title:"thames",text:""})
  #send_event("danube",{title:"danube",text:""})
  #send_event("zambeze",{title:"zambeze",text:""})
  #send_event("murray",{title:"murray",text:""})
  #send_event("yarra",{title:"yarra",text:""})
  #send_event("nile",{title:"nile",text:""})
  #send_event("tste",{title:"tste",text:""})
  #send_event("tstf",{title:"tstf",text:""})
  #send_event("tstg",{title:"tstg",text:""})

  @pFilename = "projectconfig.txt"
  @text = File.open(@pFilename)
  @text.each_line do |line|
    if line.length!=0
      @projects = line.split(",")
      @sendTitle.push @projects[0]
      sendProjectEnvironment @projects[0],@projects
    end
  end

  @envArray.each do |e|
    @f=false
    @sendTitle.each do |s|
      if s.strip==e.strip
        @f=true
        break
      end
    end
    if @f==false
      send_event(e,{title:e,text:""})
    end
  end

  @appStatus = Array.new
  
  bravoDevServer.each_with_index do|(key,value), index|

      if key == "soyou"||key=="think"||key=="lets"||key=="elope"
          @flag = false
          devApp.each do |app|
            @fadeOutAppList.each do |fadeApp|
              if key.casecmp(fadeApp.getServer.strip)==0
                if app.casecmp(fadeApp.getApp.strip)==0
                  #puts key+" "+app
                  @flag = true
                  break;
                end
              else
              end
            end
            if @flag==false
              @statu = BravoStatus.new
              @statu.setServer(key)
              @statu.setApp(app)
              @result = fetchData value,app
              @statu.setStatus(@result)
              @appStatus.push(@statu)
              #puts key+" "+app
            end
            @flag = false
          end
       end
    end
    #puts "**************"
   
  if @appOldStatus.size==0
    #put new result to
     @appStatus.each do |status| 
       @appOldStatus.push(status)
     end
  end
  @flag = false;
  @bravo_info_for_list = Hash.new({ value: 0 })
  @appStatus.each do |status|
    #data construct for list
    #puts status.getServer+" "+status.getApp
    @uni_name = status.getServer+status.getApp
    if status.getServer.strip == "elope"
      #master nsw
      @bravo_info_for_list[@uni_name] = {server:status.getServer ,app:status.getApp,status:status.getStatus,env:"nsw master"}
      send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:"nsw master",moreinfo:'',server:status.getApp+" "+status.getServer,text:status.getStatus})
    elsif status.getServer.strip == "think"
      #slaye nsw
      @bravo_info_for_list[@uni_name] = {server:status.getServer ,app:status.getApp,status:status.getStatus,env:"nsw slave"}
      send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:"nsw slave",moreinfo:'',server:status.getApp+" "+status.getServer,text:status.getStatus})
    elsif status.getServer.strip == "soyou"
      #master vic
      @bravo_info_for_list[@uni_name] = {server:status.getServer ,app:status.getApp,status:status.getStatus,env:"vic master"}
      send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:"vic master",moreinfo:'',server:status.getApp+" "+status.getServer,text:status.getStatus})
    elsif status.getServer.strip == "lets"
      #slaye vic
      @bravo_info_for_list[@uni_name] = {server:status.getServer ,app:status.getApp,status:status.getStatus,env:"vic slave"}
      send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:"vic slave",moreinfo:'',server:status.getApp+" "+status.getServer,text:status.getStatus})
    end
        #send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:status.getApp,moreinfo:'',server:status.getServer,text:status.getStatus})

  end
  #puts @bravo_info_for_list
  send_event('bravo_list', { comments: @bravo_info_for_list.values })
  #send to nile board only

end