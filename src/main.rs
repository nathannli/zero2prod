use env_logger::Env;
use sqlx::PgPool;
use std::net::TcpListener;
use zero2prod::configuration::get_configuration;
use zero2prod::startup::run;

#[tokio::main]
async fn main() -> Result<(), std::io::Error> {
    // setup env logger
    env_logger::Builder::from_env(Env::default().default_filter_or("info")).init();

    // panic if can't read config file
    let configuration = get_configuration().expect("Failed to read config file");
    // setup postgres connection
    let connection_pool = PgPool::connect(&configuration.database.connection_string())
        .await
        .expect("failed to connect to postgres");
    // init app
    let address = format!("127.0.0.1:{}", configuration.application_port);
    let listener = TcpListener::bind(address)?;
    run(listener, connection_pool)?.await
}
