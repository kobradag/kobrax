# KOBRAX

KOBRAX is a dedicated desktop process manager for [kobra Network node](https://github.com/kobradag/KOBRAD).


KOBRAX offers a miniature console using which user can re-build the kobra Network stack, upgrading kobra Network to the latest version directly from GitHub. The build process is automated via a series of scripts that, if
needed, fetch required tools (git, go, gcc) and build kobra Network on the host computer (the build includes various kobra Network utilities including, `kobrawallet`, `kobractl` and others and can be executed against any specific Git branch).  KOBRAX console can also be used to migrate kobra Network database if building a version with an updated database schema.

KOBRAX process configuration (available via a simple JSON editor) allows user to specify command-line arguments for executables, as such it is possible to configure KOBRAX to run multiple instances of kobra Network or potentially run multiple networks simultaneously (provided kobra Network nodes do not pro-actively auto-discover each-other)

Like many desktop applications, KOBRAX can run in the tray bar, out of the way.

KOBRAX is built using [NWJS](https://nwjs.io) and is compatible Windows, Linux and Mac OS X.


## Building KOBRAX

### Pre-requisites

- [Node.js 14.0.0+](https://nodejs.org/)
- Emanator - `npm install emanator@latest`
- Rust (latest, used for building kaspa miner at https://github.com/aspectron/kaspa-miner)
- Cuda linraries for kaspa miner (depends on the platform)

**NOTE:** KOBRAX build process builds and includes latest kobra Network binaries from Git master branches. 
To build from specific branches, you can use `--branch...` flags (see below).

#### Generating KOBRAX installers
```
npm install emanator@latest
git clone git@github.com:kobradag/kobrad
cd kobrad
# run emanate with one or multiple flags below
#  --portable   create a portable zipped application
#  --innosetup  generate Windows setup executable
#  --dmg        generate a DMG image for Mac OS X
#  --all        generate all OS compatible packages
# following flags can be used to reset the environment
#  --clean		clean build folders: purges cloned `GOPATH` folder
#  --reset		`--clean` + deletes downloaded/cached NWJS and NODE binaries
emanate [--portable | --innosetup | --dmg | --all]
```


DMG - Building DMG images on Mac OS requires `sudo` access in order to use system tools such as `diskutil` to generate images: 
```
sudo emanate --dmg
```

To build the windows portable deployment, run the following command:
```
emanate --portable
```

To build the Windows installer, you need to install [Innosetup](https://jrsoftware.org/isdl.php) and run:
```
emanate --innosetup
```


Emanator stores build files in the `~/emanator` folder

#### Running KOBRAX from development environment


In addition to Node.js, please download and install [Latest NWJS SDK https://nwjs.io](https://nwjs.io/) - make sure that `nw` executable is available in the system PATH and that you can run `nw` from command line.

On Linux / Darwin, as good way to install node and nwjs is as follows:

```
cd ~
mkdir bin
cd bin

#node - (must be 14.0+)
wget https://nodejs.org/dist/v14.4.0/node-v14.4.0-linux-x64.tar.xz
tar xvf node-v14.4.0-linux-x64.tar.xz
ln -s node-v14.4.0-linux-x64 node

#nwjs
wget https://dl.nwjs.io/v0.46.2/nwjs-sdk-v0.46.2-linux-x64.tar.gz
tar xvf nwjs-sdk-v0.46.2-linux-x64.tar.gz
ln -s nwjs-sdk-v0.46.2-linux-x64 nwjs

```
Once done add the following to `~/.bashrc`
```
export PATH = /home/<user>/bin/node/bin:/home/<user>/bin/nwjs:$PATH
```
The above method allows you to deploy latest binaries and manage versions by re-targeting symlinks pointing to target folders.

Once you have node and nwjs working, you can continue with KOBRAX.

KOBRAX installation:
```
npm install emanator@latest
git clone git@github.com:kobradag/kobrad
cd kobrad
npm install
emanate --local-binaries
nw .
```

#### Building installers from specific kobra Network Git branches

`--branch` argument specifies common branch name for kaspa and kasparov, for example:
```
emanate --branch=v0.4.0-dev 
```
The branch for each repository can be overriden using `--branch-<repo-name>=<branch-name>` arguments as follows:
```
emanate --branch=v0.4.0-dev --branch-kobrad=v0.3.0-dev
emanate --branch-miningsimulator=v0.1.2-dev
```

**NOTE:** KOBRAX `build` command in KOBRAX console operates in the same manner and accepts `--branch...` arguments.


## KOBRAX Process Manager

### Configuration

KOBRAX runtime configuration is declared using a JSON object.  

Each instance of the process is declared using it's **type** (for example: `kobrad`) and a unique **identifier** (`kd0`).  Most process configuration objects support `args` property that allows
passing arguments or configuration options directly to the process executable.  Depending on the process type, the configuration is passed via command line arguments (kasparov*) or configuration file (kobrad).

Supported process types:
- `kobrad` - kobra Network full node
- `kobraminer` - kobra Network sha256 miner

**NOTE:** For kobra Network, to specify multiple connection endpoints, you must use an array of addresses as follows: ` "args" : { "connect" : [ "peer-addr-port-a", "peer-addr-port-b", ...] }`

#### Default Configuration File
```js
{
	"kobrad:kd0": {
		"args": {
			"rpclisten": "0.0.0.0:44448",
			"listen": "0.0.0.0:16211",
			"profile": 7000,
			"rpcuser": "user",
			"rpcpass": "pass"
		}
	},
	"kobrad:kd1": {
		"args": {
			"rpclisten": "0.0.0.0:16310",
			"listen": "0.0.0.0:16311",
			"profile": 7001,
			"connect": "0.0.0.0:16211",
			"rpcuser": "user",
			"rpcpass": "pass"
		}
	},
	"simulator:sim0": {
        "blockdelay" : 2000,
		"peers": [ "127.0.0.1:16310" ]
	},
	"pgsql:db0": {
		"port": 18787
	},
	"mqtt:mq0": {
		"port": 18792
	},
	"kasparovsyncd:kvsd0": {
		"args": {
			"rpcserver": "localhost:16310",
			"dbaddress": "localhost:18787"
			"mqttaddress": "localhost:18792",
			"mqttuser" : "user",
			"mqttpass" : "pass"
		}
	},
	"kasparovd:kvd0": {
		"args": {
			"listen": "localhost:11224",
			"rpcserver": "localhost:16310",
			"dbaddress": "localhost:18787"
		}
	}
}
```

### Data Storage

KOBRAX stores it's configuration file as `~/.kobrad/config.json`.  Each configured process data is stored in `<datadir>/<process-type>-<process-identifier>` where `datadir` is a user-configurable location.  The default `datadir` location is `~/.kobrad/data/`.  For example, `kobrad` process with identifier `kd0` will be stored in `~/.kobrad/data/kobrad-kd0/` and it's logs in `~/.kobrad/data/kobrad-kd0/logs/kobrad.log`

### kobra Network Binaries

KOBRAX can run kobra Network from 2 locations - an integrated `bin` folder that is included with KOBRAX redistributables and `~/.kobrad/bin` folder that is created during the kobra Network build process. 

## KOBRAX Console

KOBRAX Console provides following functionality:
- Upgrading kasparov using `migrate` command
- `start` and `stop` controls stack runtime
- kobra Networkd RPC command execution
- Use of test wallet app (KOBRAX auto-configures kasparov address)
- Rebuilding kobra Network software stack from within the console

### Using kobra Networkd RPC

kobra Networkd RPC can be accessed via KOBRAX Console using the process identifier. For example:
```
$ kd0 help
$ kd0 getinfo
```
Note that RPC methods are case insensitive.

To supply RPC call arguments, you must supply and array of JSON-compliant values (numbers, double-quote-enclosed strings and 'true'/'false').  For example:
```
$ kd0 getblock "000000b22ce2fcea335cbaf5bc5e4911b0d4d43c1421415846509fc77ec643a7"
{
  "hash": "000000b22ce2fcea335cbaf5bc5e4911b0d4d43c1421415846509fc77ec643a7",
  "confirmations": 83,
  "size": 673,
  "blueScore": 46241,
  ...
}
```

