# NationBot

![Logo](.github/NationBot.png)

## About

NationBot is a discord bot for nation roleplay. With this bot you can manage your nation, invite other server members and edit its "home page"/"wiki page".

You can invite it [here](https://discord.com/api/oauth2/authorize?client_id=1091415998982275092&permissions=414531832896&scope=bot%20applications.commands).

## Nation wiki pages

These are elements you can set to be displayed:

* title (name + nickname, which can be changed)

* description (upto 2048 characters)

* link to external wiki page (your server has an external wiki? you can link it to the nation page)

* flag image (embed thumbnail: small picture on the top right)

* map image (main image: big picture on the bottom)

## Compiling and Hosting

With the nim toolchain you can run `nimble build` to build an executable. During runtime a directory called `private`, where sensitive information is stored. Your discord token should be up into `private/tokens/discord.txt`.

## Dependancies

System requirements:

* [nim toolchain](https://nim-lang.org/) (required for compilation)

* [bash](https://www.gnu.org/software/bash/) (optional, automated script)

Nimble requirements:

* [dimscord](https://github.com/krisppurg/dimscord) (discord api library)
