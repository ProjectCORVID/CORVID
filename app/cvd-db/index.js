/*

No persistence or access control for now.

"Why not just index the objects by number?"

Because then you couldn't replace something by renaming the old one.

"Why are you preserving so much of the ColdMUD semantics?"

_I have no idea..."

*/

function ObjectDB(path, core) {
  if (!(this instanceof ObjectDB))
    return new ObjectDB(path);

  this.db = {};
  this.maxid = 0;
  this.initMinimal();
  // this.loadCore(path)
}

module.exports = ObjectDB;

ObjectDB.prototype = {
  initMinimal: function () {
    createSys(this);
    createRoot(this);
    createWiz(this);
  },


  get: function (id) { return this.db[id] },

  create: function (name) {
    this.maxid++;
    return this.db[this.maxid] = new CVDObject ({
        name: name,
        id: this.maxid,
      });
  },

  destroy: function (id) {
    // Give the object a chance to clean itself up.
    try { this.db[id].sendMessage('dbDestroy'); }

    // Deleting hash elements is contra-indicated for performance reasons.
    this.db[id] = undefined;
  },

  init: function (core) {
  },
};

// Private functions below

function createSys(db) {
  var sys = db.create('sys');
  sys.
};

funciton createRoot(db) {
};

funciton createWiz(db) {
};


/*

function CVDObject(name, id) {
  var data = {}, methods = {}, name = name, id = id;

  return {
    send: function (msg, args) {
    },

}
*/