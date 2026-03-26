# Creating a nation

This article will cover the process of creating a nation, inviting members and customizing it.

[Click here to see General Commands](./being_a_member.md)

## 1. Creation and Deletion

### Creation

First you need to actually create a nation by running the `/create_nation` command.
You have to input a name for your nation there.

> This will look like this:
>
> * `/create_nation nation:New Nation`

### Deletion

To delete your nation, execute the `/delete_nation` command. You will have to provide the nations name
for confirmation, as this **cannot be undone** and data will be deleted permanently.

> This will look like this:
>
> * `/delete_nation delete_nation_confirmation:New Nation`

## 2. Inviting Members

### Sending an invitation

Every member can have one nation, they but can be invited to multiple. This way a
person can create unions of nations.

To invite a person run the `/invite_member` command.

> This will look like this:
>
> * `/invite_member user:@some_user`

### Removing a member

As a nation owner you can remove members by running the `/remove_member` command.

> This will look like this:
>
> * `/remove_member user:some_user`

## 3. Customization

### Nickname

Set the nations nickname by running the `/set_nation_nickname` command. Nicknames will be displayed
in brackets next to the nations name (Example: `New Nation (New Nickname)`).

> This will look like this:
>
> * `/set_nation_nickname nickname:New Nickname`

### Description

Set the nations description by running the `/set_nation_description` command.

> This will look like this:
>
> * `> This will look like this:
>
> * `/set_nation_description description:My Nation is really cool, yeah!`

### Flag

Set the nations flag by running the `/set_nation_flag` command and provide a link to an image.

> This will look like this:
>
> * `/set_nation_flag link:https://www.nirokay.com/some_image.png`

### Learn more with the `/help` command

You can run the `/help` command to find more customization commands.
