# RL/SRL Playground for Apache/PHP

This is an adaptation of the RL/SRL Playground (from [this repo](https://github.com/vadgaard/rl-srl-web)) that makes the backend work on Apache servers with PHP. This was done specifically to be able to host the interface on DIKU's server at [https://topps.diku.dk](https://topps.diku.dk) which (unbeknownst to me when writing the server backend in Haskell) runs on Apache/PHP.

The original RL/SRL Playground (hosted on my own server with a Haskell backend) can be found at [https://rev.vadg.io](https://rev.vadg.io).

The Apache/PHP port can be found at [https://topps.diku.dk/pirc/rl-srl](https://topps.diku.dk/pirc/rl-srl).

I have chosen to also host the port on my own server at [https://rev2.vadg.io](https://rev2.vadg.io).

# TODO
- I hope to streamline the structure of the repos in the future such that I have a single repo for the interpreters that can simply be included as a submodule for both backends
- A complete (optimized) rewrite of the interpreters would be nice, but it's not at all a priority right now
