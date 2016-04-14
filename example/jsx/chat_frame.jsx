var ChatFrame = React.createClass({
  getInitialState: function() {
    return { ws: null, lines: [] };
  },
  withState: function(key, func) {
    var state = this.state;
    state[key] = func(state[key]);
    this.setState(state);
  },
  clickHandler: function(e) {
    e.stopPropagation();
    e.preventDefault();

    var channel = e.target.innerHTML.trim();
    var user = this.refs.user.value;
    if (!user || user.length === 0) {
      this.props.opts.addError("Username '" + user + "' too short");
      return;
    }
    this.withState("ws", function(ws) {
      if (ws) {
        ws.close();
      }
      return SocketHelper.init(channel, user, { onmessage: this.onmessage });
    }.bind(this));
  },
  onmessage: function(payload) {
    var time = (payload.timeStampt ? moment(payload.timeStamp/1000) :
      moment()).format('hh:mm:ss');
    var line;
    if (payload.action === "join") {
      line = "[" + time + "] " + payload.user + " has joined " +
        payload.channel;
    } else if (payload.action === "leave") {
      line = "[" + time + "] " + payload.user + " has left " + payload.channel;
    } else if (payload.action === "message") {
      line = "[" + time + "] " + payload.user + ": " + payload.message;
    }
    this.withState("lines", function(list) {
      list.splice(0, 0, line);
      return list;
    });
  },
  submitHandler: function(e) {
    e.stopPropagation();
    e.preventDefault();
  },
  channels: function() {
    return <div>{
      this.props.channels.map(function(elem) {
        return <a href="#" key={elem} onClick={this.clickHandler}
          className="btn btn-default">{elem}</a>;
      }.bind(this))
    }</div>;
  },
  render: function() {
    if (this.props.channels.length === 0) {
      return null;
    }
    return <div>
      <form className="form-inline" onSubmit={this.submitHandler}>
        <input className="form-control" ref="user" placeholder="Username" />
        {this.channels()}
      </form>
      <Chat ws={this.state.ws} lines={this.state.lines}
        opts={this.props.opts} />
    </div>;
  }
});
