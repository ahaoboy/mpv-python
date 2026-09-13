mp.command_native_async({
  name: "subprocess",
  args: ["python", "--version"],
  capture_stdout: true,
  capture_stderr: true,
  playback_only: false
}, function (success, result, err) {
  var out = success && result ? (result.stdout + result.stderr).trim() : "";
  mp.osd_message(out || "python: " + (err || "not found"), 1000);
});
