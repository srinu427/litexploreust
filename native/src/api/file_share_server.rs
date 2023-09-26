//#[macro_use] extern crate rocket;

use rocket::{get, routes, Shutdown};
use rocket::config::LogLevel;

#[get("/hello")]
fn hello() -> &'static str {
    "Hello, world!"
}

pub struct RunnableShareServer {
    shutdown_handle: Option<Shutdown>,
}

impl RunnableShareServer {
    pub(crate) fn new() -> Self {
        Self {
            shutdown_handle: None,
        }
    }

    pub(crate) fn is_running(&self) -> bool {
        self.shutdown_handle.is_some()
    }

    pub(crate) async fn start_server(&mut self, port: u16) {
        if self.shutdown_handle.is_none(){
            let shutdown_config = rocket::config::Shutdown {
                ctrlc: false,
                ..Default::default()
            };
            let rocket_config = rocket::Config {
                port,
                log_level: LogLevel::Off,
                shutdown: shutdown_config,
                ..Default::default()
            };
            let server_build = rocket::custom(rocket_config).mount("/", routes![hello]);
            let rocket_handle = server_build.ignite().await.unwrap();
            let shutdown_handle = rocket_handle.shutdown();
            rocket::tokio::spawn(rocket_handle.launch());
            self.shutdown_handle = Some(shutdown_handle);
        }
    }

    pub(crate) async fn stop_server(&mut self) {
        if self.shutdown_handle.is_some() {
            let shutdown = self.shutdown_handle.clone().unwrap();
            let notify_shutdown = shutdown.clone();
            notify_shutdown.notify();
            shutdown.await;
            self.shutdown_handle = None;
        }
    }
}
