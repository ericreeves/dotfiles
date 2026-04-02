use std::io::Write;
use std::os::unix::net::UnixStream;

fn main() {
    let event = std::env::args().nth(1).unwrap_or_default();
    if event.is_empty() {
        return;
    }
    if let Ok(mut stream) = UnixStream::connect("/tmp/aerospace-helper.sock") {
        let _ = writeln!(stream, "{}", event);
    }
}
