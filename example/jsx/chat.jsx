var Chat = React.createClass({
  messageHandler: function(e) {
    e.stopPropagation();
    e.preventDefault();

    var msg = this.refs.message.value;
    if (msg.length === 0) {
      this.props.opts.addError("Message empty");
      return;
    }
    this.props.ws.send(msg);
    this.refs.message.value = "";
  },
  chat: function() {
    if (!this.props.ws) {
      return "";
    }
    return <form className="form-inline">
      <input className="form-control" ref="message" placeholder="Message" />
      <button type="submit" className="btn btn-default"
        onClick={this.messageHandler}>Send</button>
    </form>;
  },
  lines: function() {
    if (this.props.lines.length === 0) {
      return "";
    }
    return <pre>
      {this.props.lines.join("\n")}
    </pre>;
  },
  render: function() {
    return <div>
      {this.chat()}
      {this.lines()}
    </div>;
  }
});
