#!/usr/bin/python3
import disc
import sys,os

text = ' '.join(sys.argv[1::]).replace('\\n', '\n')
chanid=884855574095876136
bot = disc.disc(os.getenv('DISCORD_TOKEN'))
bot.send(chanid, text)
