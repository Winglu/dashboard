# :first_in sets how long it takes before the job is first run. In this case, it is run immediately

bravoPreServer = Hash.new
#pre
bravoPreServer['arwon'] = "172.19.128.51"
bravoPreServer['brew'] = "172.19.128.52"
bravoPreServer['streak'] = "172.19.128.53"
bravoPreServer['daacha'] = "172.19.128.54"


arwonApp = Array.new
arwonApp.push("prdv")

brewApp = Array.new
brewApp.push("prdv")

streakApp = Array.new
streakApp.push("prdn")

daachaApp = Array.new
daachaApp.push("prdn")

def fetchDataPre(serverIP,appName)
  @counter = 0
  @status = "dead"
  begin
    @status = ""
    Net::SSH.start(serverIP, USER, :password => PASS ) do|ssh|
      #puts serverIP
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

SCHEDULER.every '15s', allow_overlapping:false do |job|

  @appStatusPre = Array.new
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
      send_event("bravo_app_status_#{@fadeApp.getServer}_#{@fadeApp.getApp}",{title:"",moreinfo:'fade',server:@fadeApp.getApp+" "+@fadeApp.getServer,text:""})
    end
  end

  bravoPreServer.each_with_index do|(key,value), index|
    if key.casecmp('arwon')==0
      @flag = false;
      arwonApp.each do |app|
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
          @statu2 = BravoStatus.new
          @statu2.setServer(key)
          #puts app
          @statu2.setApp(app)
          @result = fetchDataPre value,app
          @statu2.setStatus(@result)
          @appStatusPre.push(@statu2)
        end
        @flag=false
      end
    elsif key.casecmp('brew')==0
      @flag = false;
      brewApp.each do |app|
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
        if @flag ==false
          @statu2 = BravoStatus.new
          @statu2.setServer(key)
          #puts app
          @statu2.setApp(app)
          @result = fetchDataPre value,app
          @statu2.setStatus(@result)
          @appStatusPre.push(@statu2)

        end
        @flag=false
      end
    elsif key =='streak'
      @flog = false;
      streakApp.each do |app|
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
          @statu2 = BravoStatus.new
          @statu2.setServer(key)
          #puts app
          @statu2.setApp(app)
          @result = fetchDataPre value,app
          @statu2.setStatus(@result)
          @appStatusPre.push(@statu2)

        end
        @flag=false
      end
    elsif key.casecmp('daacha')==0
      @flog = false;
      daachaApp.each do |app|
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
          @statu2 = BravoStatus.new
          @statu2.setServer(key)
          #puts app
          @statu2.setApp(app)
          @result = fetchDataPre value,app
          @statu2.setStatus(@result)
          @appStatusPre.push(@statu2)

        end
        @flag=false
      end
    end
  end
  @bravo_info_for_list = Hash.new({ value: 0 })
  @appStatusPre.each do |status1|

    @uni_name1=status1.getServer+status1.getApp

    if status1.getServer.strip=="streak"
      #master nsw
      @bravo_info_for_list[@uni_name1] = {server:status1.getServer ,app:status1.getApp,status:status1.getStatus,env:"nsw master"}
      send_event("bravo_app_status_#{status1.getServer}_#{status1.getApp}",{title:"nsw master",moreinfo:'',server:status1.getApp+" "+status1.getServer,text:status1.getStatus})
    elsif status1.getServer.strip =="daacha"
      #slaye nsw
      @bravo_info_for_list[@uni_name1] = {server:status1.getServer ,app:status1.getApp,status:status1.getStatus,env:"nsw slave"}
      send_event("bravo_app_status_#{status1.getServer}_#{status1.getApp}",{title:"nsw slave",moreinfo:'',server:status1.getApp+" "+status1.getServer,text:status1.getStatus})
    elsif status1.getServer.strip == "brew"
      #master vic
      @bravo_info_for_list[@uni_name1] = {server:status1.getServer ,app:status1.getApp,status:status1.getStatus,env:"vic master"}
      send_event("bravo_app_status_#{status1.getServer}_#{status1.getApp}",{title:"vic master",moreinfo:'',server:status1.getApp+" "+status1.getServer,text:status1.getStatus})
    elsif status1.getServer.strip == "arwon"
      #slaye vic

      @bravo_info_for_list[@uni_name1] = {server:status1.getServer ,app:status1.getApp,status:status1.getStatus,env:"vic slave"}
      #puts @bravo_info_for_list[@uni_name1]
      send_event("bravo_app_status_#{status1.getServer}_#{status1.getApp}",{title:"vic slave",moreinfo:'',server:status1.getApp+" "+status1.getServer,text:status1.getStatus})
    end
  end
  send_event('nile_bravo_list', { comments: @bravo_info_for_list.values })
end