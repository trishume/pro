# Pro

`pro` is a little utility to wrangle your git repositories.
At the moment all it does is provide the very useful function of letting
you instantly cd to git repositories based on fuzzy matching.

## Pro CD

Use the `pro install` command and follow the prompts to install the pro cd command.
As part of the install process you can name it whatever you want but it
defaults to `pd`.

### Examples

    **~/randomFolder/ $** pd pro
    **pro/ $** pwd 
    /Users/tristan/Box/Dev/Projects/pro
    **pro/ $** pd eye
    **eyeLike/ $** pwd
    /Users/tristan/Box/Dev/Projects/eyeLike
    **eyeLike/ $** pd web
    **Website/ $** pwd
    /Users/tristan/Box/Dev/Website/

## Installation

Add this line to your application's Gemfile:

    gem 'pro'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pro

## Usage

    $ pro help
    pro is a command to help you manage your git repositories.

    base directory ==========
    pro works from a base directory for efficiency.
    this is the folder that contains all your other git repositories;
    they don't have to be at the base level, just somewhere down the tree.

    to set the base directory set the pro_base environment variable or make 
    a ~/.probase file containing the path.

    commands ===============
    pro search <query> - prints path of git repo that matches query.
    pro install - install the pro cd command. cd to a directory by fuzzy git repo matching.
    pro help - display help

    cd command ============
    you can use the 'pro install' command to install a wrapper function that allows
    you to cd to git repositories in your pro base wherever you are based on fuzzy matching.

    example:

      ~/randomfolder/ $ pd pro
      pro/ $ pwd 
      /users/tristan/box/dev/projects/pro


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
