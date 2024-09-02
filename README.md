# PNEngine

PNEngine is a fully external 3D engine for GameMaker with support for modding
and local/online multiplayer with up to 4 players.

In order to build this, you will need to import the extensions
[GMEXT-FMOD](https://github.com/YoYoGames/GMEXT-FMOD)
and [NekoPresence](https://github.com/nkrapivin/NekoPresence) to the project's
Extensions folder using the GameMaker IDE.

## Multiplayer

### Local

PNEngine uses input device hotswapping by default. If you want to add other
players by using different input devices, launch the game with the
`-multiplayer` command line.

You can assign a new player to an input device by pressing any button on it.
Once assigned, that player is readied and will be able to play on level change.
Players can unready or leave the game by pressing `Backspace` on their keyboard
or `Select` on their gamepad.

### Online (EXPERIMENTAL)

Deterministic lockstep is used in order to sync games, so you need low latency
with other players in order to play with minimal input delay.

Only player input and level changes are synced. Game flags and player states
currently don't get synced, so you will be prone to desyncs if you rehost or
reconnect from a previous session. In this case, all players should relaunch
PNEngine instead.

- Open the developer console by pressing `~` (`Ö` on Nordic keyboard layouts).
- Host the game on `lvlTitle` with the console command `host [port]`. Other players can connect with `connect <ip> [port]`.

## Credits

PNEngine was created by **[Can't Sleep](https://cantsleep.cc)** and **[nonk](https://nonk.dev)**.

The curve shader is from **[Mors](https://mors-games.com/)**' [Super Mario 64 Plus Launcher](https://github.com/MorsGames/sm64plus-launcher).

### Special Thanks

- **[Alynne Keith](https://offalynne.neocities.org)** and **[Co](https://offalynne.github.io/Input/#/6.0/Credits)** for [Input](https://github.com/offalynne/Input)
- **[DragoniteSpam](https://github.com/DragoniteSpam)** and **[TheSnidr](https://thesnidr.com)** for information about 3D in GameMaker
- **Jaydex** and **Soh** for beta testing multiplayer
- **[Juju Adams](http://www.jujuadams.com)** for [Scribble](https://github.com/JujuAdams/Scribble)
- **[katsaii](https://www.katsaii.com)** for [Catspeak](https://www.katsaii.com/catspeak-lang)
- **[Patrik Kraif](https://github.com/kraifpatrik)** for [BBMOD](https://blueburn.cz/bbmod)
- **[TabularElf](https://tabularelf.com)** for beta testing and [Canvas](https://github.com/tabularelf/Canvas), [Collage](https://github.com/tabularelf/Collage), [Lexicon](https://github.com/tabularelf/lexicon) and [MultiClient](https://github.com/tabularelf/MultiClient)
