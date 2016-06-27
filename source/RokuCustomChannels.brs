Sub Main()
    
    initTheme()
  
    gridstyle = "Flat-Square"

    while gridstyle <> ""
        screen=preShowGridScreen(gridstyle)
        gridstyle = channelGridScreen(screen, gridstyle)
    end while

End Sub

Sub initTheme()

    app = CreateObject("roAppManager")
    app.SetTheme(CreateDefaultTheme())

End Sub

' Change grid theme in this function
Function CreateDefaultTheme() as Object

    theme = CreateObject("roAssociativeArray")

    'theme.ThemeType = "generic-dark"

    theme.GridScreenBackgroundColor = "#000000"
    theme.GridScreenMessageColor    = "#808080"
    theme.GridScreenRetrievingColor = "#CCCCCC"
    theme.GridScreenListNameColor   = "#FFFFFF"

    theme.GridScreenDescriptionTitleColor    = "#393a3c"
    theme.GridScreenDescriptionDateColor     = "#FF005B"
    theme.GridScreenDescriptionRuntimeColor  = "#5B005B"
    theme.GridScreenDescriptionSynopsisColor = "#606000"
    
    theme.CounterTextLeft           = "#FF0000"
    theme.CounterSeparator          = "#00FF00"
    theme.CounterTextRight          = "#0000FF"
    
    return theme

End Function

Function preShowGridScreen(style as string) As Object

    m.port=CreateObject("roMessagePort")
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(m.port)
    screen.SetDisplayMode("best-fit")

    screen.SetGridStyle(style)
    return screen

End Function

Function channelGridScreen(screen As Object, gridstyle as string) As string

    print "enter channelGridScreen"

    categoryList = getCategoryList()
    screen.setupLists(categoryList.count())
    screen.SetListNames(categoryList)
    for i = 0 to categoryList.count()-1
        screen.SetContentList(i, getChannelsForCategoryItem(categoryList[i]))
    end for
    screen.Show()

    while true
        print "Waiting for message"
        msg = wait(0, m.port)
        if type(msg) = "roGridScreenEvent" then
            if msg.isListItemFocused() then
                print"list item focused | current show = "; msg.GetIndex()
            else if msg.isListItemSelected() then
                row = msg.GetIndex()
                selection = msg.getData()
                print "list item selected row= "; row; " selection= "; selection

                m.curShow = displayChannelDetailScreen(getChannelsForCategoryItem(categoryList[row])[selection])
            else if msg.isScreenClosed() then
                return ""
            end if
        end If
    end while


End Function

Function displayChannelDetailScreen(showDetail as Object) As Integer

    'add code to create springboard, for now we do nothing
    print"Title selected is "; showDetail.title
    displayVideo(showDetail)
    return 1

End Function

Function getCategoryList() As Object

    ' ADD CHANNEL CATEGORIES TO THIS LIST
    categoryList = ["Indian News", "World News"]
    return categoryList

End Function

' ADD CHANNEL PROPERTIES TO channelListByCat Object under the corresponding channel category
Function getChannelsForCategoryItem(category As String) As Object

    print "getting channels for category "; category

    channelListByCat = {
        "World News": [
            {
                url : "http://web-cache.stream.ne.jp/www11/nhkworld-tv/global/222714/live_tv.m3u8"
                qualities : ["SD"]
                streamformat : "hls"
                title : "NHK World"
                HDPosterUrl:"pkg:/images/nhk-world.jpg"
            }
            {
                url : "http://rt-a.akamaihd.net/ch_01@325605/480p.m3u8#.m3u8"
                qualities : ["SD"]
                streamformat : "hls"
                title : "RT News"
                HDPosterUrl:"pkg:/images/rt-news.jpg"
            }
        ]
        "Indian News": [
            {
                url : "http://ndtv.live-s.cdn.bitgravity.com/cdn-live-b7/_definst_/ndtv/live/ndtv247live.smil/playlist.m3u8"
                qualities : ["SD"]
                streamformat : "hls"
                title : "NDTV 24/7 Live stream"
                HDPosterUrl:"pkg:/images/ndtv-24x7.jpg"
            }
            {
                url : "http://ndtv.live-s.cdn.bitgravity.com/cdn-live-b7/_definst_/ndtv/live/ndtvindialive.smil/playlist.m3u8"
                qualities : ["SD"]
                streamformat : "hls"
                title : "NDTV India Live stream"
                HDPosterUrl:"pkg:/images/ndt-india.png"
            }
        ]
    }

    return channelListByCat[category]
End Function

Function displayVideo(args As Dynamic)
    print "Displaying video: "
    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(p)

    'bitrates  = [0]          ' 0 = no dots, adaptive bitrate
    'bitrates  = [348]    ' <500 Kbps = 1 dot
    'bitrates  = [664]    ' <800 Kbps = 2 dots
    'bitrates  = [996]    ' <1.1Mbps  = 3 dots
    'bitrates  = [2048]    ' >=1.1Mbps = 4 dots
    bitrates  = [0]    

    if type(args) = "roAssociativeArray"
        print"url selected is "; type(args.url); " -- "; args.url
        if type(args.url) = "roString" and args.url <> "" then
            urls = [args.url]
        end if
        if type(args.StreamFormat) = "roString" and args.StreamFormat <> "" then
            StreamFormat = args.StreamFormat
        end if
        if type(args.title) = "roString" and args.title <> "" then
            title = args.title
        else 
            title = ""
        end if
        if type(args.qualities) = "roArray" then
            qualities = args.qualities
        else 
            qualities = []
        end if
        if type(args.srt) = "roString" and args.srt <> "" then
            srt = args.StreamFormat
        else 
            srt = ""
        end if
    end if
    
    videoclip = CreateObject("roAssociativeArray")
    videoclip.StreamBitrates = bitrates
    videoclip.StreamUrls = urls
    videoclip.StreamQualities = qualities
    videoclip.StreamFormat = StreamFormat
    videoclip.Title = title
    'print "srt = ";srt
    'if srt <> invalid and srt <> "" then
    '   videoclip.SubtitleUrl = srt
    'end if
    
    video.SetContent(videoclip)
    video.show()

    lastSavedPos   = 0
    statusInterval = 10 'position must change by more than this number of seconds before saving

    while true
        msg = wait(0, video.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then 'ScreenClosed event
                print "Closing video screen"
                exit while
            else if msg.isPlaybackPosition() then
                nowpos = msg.GetIndex()
                if nowpos > 10000
                    
                end if
                if nowpos > 0
                    if abs(nowpos - lastSavedPos) > statusInterval
                        lastSavedPos = nowpos
                    end if
                end if
            else if msg.isRequestFailed()
                print "play failed: "; msg.GetMessage()
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        end if
    end while
End Function