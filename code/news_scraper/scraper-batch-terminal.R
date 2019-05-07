# start
system("launchctl load /Library/LaunchAgents/newsRssScraper.plist")
system("launchctl start newsRssScraper")
system("launchctl load /Library/LaunchAgents/newsRssScraperMonitor.plist")
system("launchctl start newsRssScraperMonitor")
system("launchctl list")




# stop
system("launchctl stop newsRssScraper")
system("launchctl stop newsRssScraperMonitor")
system("launchctl unload /Library/LaunchAgents/newsRssScraper.plist")
system("launchctl unload /Library/LaunchAgents/newsRssScraperMonitor.plist")
