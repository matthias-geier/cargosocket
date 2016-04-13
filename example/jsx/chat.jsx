var Chat = React.createClass({
  getInitialState: function() {
    return { ws: null, lines: [] };
  },
  clickHandler: function(e) {
    e.stopPropagation();
    e.preventDefault();

    var channel = e.target.innerHTML.trim();
    var user = this.refs.user.value;
    if (!user || user.length === 0) {
      this.props.addError("Username '" + user + "' too short");
      return;
    }
    this.resetWs();
    var ws = new WebSocket('ws://localhost:3001/talk?channel=' + channel +
      '&user=' + user);
    ws.onmessage = function(m) {
      var payload = m.data;
      if (typeof(payload) !== 'object') {
        payload = JSON.parse(payload);
      }
      payload = payload.body;
      var time = moment(m.timeStamp/1000).format('hh:mm:ss');
      if (payload.action === "join") {
        this.addLine("[" + time + "] " + payload.user + " has joined " +
          payload.channel);
      } else if (payload.action === "leave") {
        this.addLine("[" + time + "] " + payload.user + " has left " +
          payload.channel);
      } else if (payload.action === "message") {
        this.addLine("[" + time + "] " + payload.user + ": " + payload.message);
      }
    }.bind(this);
    var state = this.state;
    state.ws = ws;
    this.setState(state);
  },
  messageHandler: function(e) {
    e.stopPropagation();
    e.preventDefault();

    var msg = this.refs.message.value;
    if (msg.length === 0) {
      this.props.addError("Message empty");
      return;
    }
    this.state.ws.send(msg);
    this.refs.message.value = "";
  },
  addLine: function(line) {
    var state = this.state;
    state.lines.splice(0, 0, line);
    this.setState(state);
  },
  resetWs: function() {
    var state = this.state;
    if (state.ws) { state.ws.close(); }
    state.ws = null;
    state.lines = [];
    this.setState(state);
  },
  channels: function() {
    return <div>{
      this.props.channels.map(function(elem) {
        return <a href="#" key={elem} onClick={this.clickHandler}
          className="btn btn-default">{elem}</a>;
      }.bind(this))
    }</div>;
  },
  chat: function() {
    if (!this.state.ws) { return ""; }
    return <div>
      <form className="form-inline">
        <input className="form-control" ref="message" placeholder="Message" />
        <button type="submit" className="btn btn-default"
          onClick={this.messageHandler}>Send</button>
      </form>
      {this.lines()}
    </div>;
  },
  lines: function() {
    return <pre>{
      this.state.lines.join("\n")
    }</pre>;
  },
  render: function() {
    return <div>
      <form className="form-inline">
        <input className="form-control" ref="user" placeholder="Username" />
        {this.channels()}
      </form>
      {this.chat()}
    </div>;
  }
});
