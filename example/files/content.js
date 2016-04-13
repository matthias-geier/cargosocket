var Content = React.createClass({displayName: "Content",
  getInitialState: function() {
    return { channels: [], errors: [] };
  },
  setChannels: function(channels) {
    var state = this.state;
    state.channels = channels || [];
    this.setState(state);
  },
  updateChannels: function() {
    promise.get("/api/talk").then(function(err, text, xhr) {
      var payload = JSON.parse(text);
      if (payload.status === 200) {
        this.setChannels(payload.body);
      }
    }.bind(this));
  },
  shiftError: function() {
    var state = this.state;
    state.errors = state.errors.slice(1);
    this.setState(state);
  },
  addError: function(err) {
    var state = this.state;
    state.errors.push(err);
    this.setState(state);

    var p = new promise.Promise();
    setTimeout(function(){ p.done(); }, 5000);
    p.then(this.shiftError);
  },
  componentDidMount: function() {
    this.updateChannels();
  },
  render: function() {
    return React.createElement("div", {className: "container"}, 
      React.createElement("h2", null, "Channels"), 
      
        this.state.errors.map(function(err, i) {
          return React.createElement("p", {key: i, className: "bg-danger"}, err);
        }.bind(this)), 
      
      React.createElement(AddChannel, {updateChannels: this.updateChannels, 
        addError: this.addError}), 
       this.state.channels.length === 0 ?
        "No channels found" :
        React.createElement("ul", null,  this.state.channels.map(function(elem) {
          return React.createElement(ChannelItem, {key: elem, name: elem, 
            updateChannels: this.updateChannels, addError: this.addError});
        }.bind(this)) ), 
      
      React.createElement(Chat, {channels: this.state.channels, addError: this.addError})
    );
  }
});
