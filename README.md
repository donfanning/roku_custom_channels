# roku_custom_channels
A simple roku app that allows you to add your own channels and watch them on your tv

# Running and Debugging app on Roku 
https://sdkdocs.roku.com/display/sdkdoc/Loading+and+Running+Your+Application+Walkthrough
https://sdkdocs.roku.com/display/sdkdoc/Debugging+Your+Application

For zipping files, use command 
`zip -9 -r roku_custom_channels.zip ./`

# Adding your own channel streams

Look for `getChannelsForCategoryItem` function in RokuCustomChannels.brs file, and modify the `channelListByCat` object with the properties of your channel. Example 

To add NHK world stream, add the following object to `channelListByCat`. Also add the logo image of your channel to the images dir. 

```
{
  url : "http://web-cache.stream.ne.jp/www11/nhkworld-tv/global/222714/live_tv.m3u8"
  qualities : ["SD"]
  streamformat : "hls"
  title : "NHK World"
  HDPosterUrl:"pkg:/images/nhk-world.jpg"
}
```
