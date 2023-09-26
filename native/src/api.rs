mod file_share_server;

use file_share_server::RunnableShareServer;
use rocket::tokio;

fn start_lit_share_server() -> RunnableShareServer {
    let mut share_server = RunnableShareServer::new();
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(share_server.start_server(4278));
    share_server
}

fn stop_lit_share_server(mut share_server: RunnableShareServer) {
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(share_server.stop_server());
}
