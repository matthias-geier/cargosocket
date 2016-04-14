var Chat = React.createClass({displayName: "Chat",
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
    return React.createElement("form", {className: "form-inline"}, 
      React.createElement("input", {className: "form-control", ref: "message", placeholder: "Message"}), 
      React.createElement("button", {type: "submit", className: "btn btn-default", 
        onClick: this.messageHandler}, "Send")
    );
  },
  lines: function() {
    if (this.props.lines.length === 0) {
      return "";
    }
    return React.createElement("pre", null, 
      this.props.lines.join("\n")
    );
  },
  render: function() {
    return React.createElement("div", null, 
      this.chat(), 
      this.lines()
    );
  }
});
