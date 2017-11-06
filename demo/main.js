// Generated by CoffeeScript 1.12.3
(function() {
  'use strict';
  var draw, main;

  draw = function(board, tileSize, scale) {
    var canvas, context, i, j, k, l, ref, ref1, tile;
    canvas = document.getElementById('can');
    canvas.width = tileSize.x * board.size.x;
    canvas.height = tileSize.y * board.size.y;
    canvas.style.width = (canvas.width * scale) + "px";
    canvas.style.height = (canvas.height * scale) + "px";
    context = canvas.getContext('2d');
    for (i = k = 0, ref = board.size.y; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
      for (j = l = 0, ref1 = board.size.x; 0 <= ref1 ? l < ref1 : l > ref1; j = 0 <= ref1 ? ++l : --l) {
        tile = board.get(Vec2.make(j, i));
        if (tile != null) {
          context.drawImage(tile.image, j * tileSize.x, i * tileSize.y);
        }
      }
    }
  };

  main = function(src, srcSize, arg) {
    var image, outSize, scale;
    outSize = arg.outSize, scale = arg.scale;
    image = new Image;
    image.src = src;
    image.addEventListener('load', function() {
      var canvas, context;
      canvas = document.createElement('canvas');
      canvas.width = image.width;
      canvas.height = image.height;
      context = canvas.getContext('2d');
      context.drawImage(image, 0, 0);
      return Tileset.getTileset(canvas, srcSize).then(function(tileset) {
        var board, tileSize;
        tileSize = Object.assign({}, (tileset.get('t0-0')).tileData.size);
        if (outSize == null) {
          outSize = Vec2.make(Math.floor(Math.floor(window.innerWidth / tileSize.x) / scale), Math.floor(Math.floor(window.innerHeight / tileSize.y) / scale));
        }
        board = Generator.generate(outSize, tileset);
        draw(board, tileSize, scale);
      });
    });
  };

  (function() {
    var options;
    options = {
      scale: location.hash ? Number(location.hash.slice(1)) : 1
    };
    return main('4.png', Vec2.make(5, 11), options);
  })();

}).call(this);
