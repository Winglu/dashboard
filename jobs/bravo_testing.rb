# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/ssh'
require 'net/telnet'
require 'json'



bravoTestingServer = Hash.new
#testing
bravoTestingServer['black'] = "10.26.128.51"
bravoTestingServer['caviar'] = "10.26.128.52"
bravoTestingServer['white'] = "10.26.128.53"
bravoTestingServer['nose'] = "10.26.128.54"

nswApp = Array.new
nswApp.push("prdn")
nswApp.push("sitn")
nswApp.push("tstd")
nswApp.push("tste")
nswApp.push("tstf")
nswApp.push("tstg")
nswApp.push("tsth")
nswApp.push("tstn")


vicApp = Array.new
vicApp.push("prdv")
vicApp.push("sitv")
vicApp.push("tstd")
vicApp.push("tste")
vicApp.push("tstf")
vicApp.push("tstg")
vicApp.push("tsth")
vicApp.push("tstv")



SCHEDULER.every '15s', allow_overlapping:false do |job|
  @appStatusTesting = Hash.new()
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
      #puts "bravo_app_status_#{@fadeApp.getServer}_#{@fadeApp.getApp}"
      send_event("bravo_app_status_#{@fadeApp.getServer.strip}_#{@fadeApp.getApp.strip}",{title:"",moreinfo:'fade',server:@fadeApp.getApp+" "+@fadeApp.getServer,text:""})
    end
  end


  bravoTestingServer.each_with_index do|(key,value), index|

    if key == 'black' || key == 'caviar'
      @flag = false
      #puts value
      nswApp.each do |app|
        #fetch data

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
        if @flag == false
          @statu1 = BravoStatus.new
          @statu1.setServer(key)
          @statu1.setApp(app)
          @result = fetchData value,app
          #puts @result
          @statu1.setStatus(@result)
          @uni_name = @statu1.getServer+@statu1.getApp
          @appStatusTesting[@uni_name]=@statu1

        end
        @flag = false;
      end
    elsif key =='white'||key=='nose'
      @flag = false
      vicApp.each do |app|
        @fadeOutAppList.each do |fadeApp|
          if key.casecmp(fadeApp.getServer.strip)==0
            if app.casecmp(fadeApp.getApp.strip)==0
              @flag = true
              #puts key+" "+app
              break;

            end
          else

          end
        end
        if @flag == false
          @statu1 = BravoStatus.new
          @statu1.setServer(key)
          @statu1.setApp(app)
          @result = fetchData value,app
          @statu1.setStatus(@result)
          @uni_name = @statu1.getServer+@statu1.getApp
          @appStatusTesting[@uni_name]=@statu1
        end
        @flag=false
      end
    end
  end

  @appStatusTesting.each do |key,status|
    #data construct for list
    @uni_name = status.getServer+status.getApp
    #puts @uni_name
    if status.getServer.strip=="black"
      #master nsw
      #@bravo_info_for_list[@uni_name] = {server:status.getServer ,app:status.getApp,status:status.getStatus,env:"nsw master"}
      #puts status.getServer+","+status.getApp
      send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:"nsw master",moreinfo:'',server:status.getApp+" "+status.getServer,text:status.getStatus})
    elsif status.getServer.strip =="caviar"
      #slaye nsw
      #@bravo_info_for_list[@uni_name] = {server:status.getServer ,app:status.getApp,status:status.getStatus,env:"nsw slave"}
      send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:"nsw slave",moreinfo:'',server:status.getApp+" "+status.getServer,text:status.getStatus})
    elsif status.getServer.strip == "white"
      #master vic
      #@bravo_info_for_list[@uni_name] = {server:status.getServer ,app:status.getApp,status:status.getStatus,env:"vic master"}
      send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:"vic master",moreinfo:'',server:status.getApp+" "+status.getServer,text:status.getStatus})
    elsif status.getServer.strip == "nose"
      #slaye vic
      #@bravo_info_for_list[@uni_name] = {server:status.getServer ,app:status.getApp,status:status.getStatus,env:"vic slave"}
      send_event("bravo_app_status_#{status.getServer}_#{status.getApp}",{title:"vic slave",moreinfo:'',server:status.getApp+" "+status.getServer,text:status.getStatus})
    end
  end
  @appStatusTesting=nil

end