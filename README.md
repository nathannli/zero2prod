# os specific setup
p.5

# cargo installs
cargo install cargo-watch cargo-audit <br>
cargo install --version='~0.7' sqlx-cli --no-default-features --features rustls,postgres

# rustup installs
rustup component add clippy rustfmt

# .cargo/config.toml
check for package dependencies

# database setup
p.55
script needs to be run at root of project (next to migrations folder)

# current page
p. 86 @ 4.0

# dependencies
## linux (not always?)
- apt install pkg-config libssl-dev postgresql-client

# check if webserver alive
after running `cargo run`, run `curl -v localhost:8000/health_check`, should return 200
< HTTP/1.1 200 OK
