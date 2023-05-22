//TODO REFACTOR

function vecDrawAdd {
  parameter vlex, vstart, vend, color, label,
  scale is 1,
  width is 0.1.

  if vlex:keys:contains(label) {
    set vlex[label]:START to vstart.
    set vlex[label]:VEC to vend.
    set vlex[label]:COLOR to color.
    set vlex[label]:scale to scale.
    set vlex[label]:width to width.
  }else{
    vlex:add(label,vecDraw(vstart,vend,color,label,scale,true,width)).
  }
}

function drawArrowTo {
  parameter vlex, vec, color, label, scale is 1, width is 0.1.

  if vlex:keys:contains(label) {
    set vlex[label]:START to v(0,0,0).
    set vlex[label]:VEC to v(0,0,0).
    set vlex[label]:COLOR to color.
    set vlex[label]:scale to scale.
    set vlex[label]:width to width.
  }else{
    vlex:add(label,vecDraw(v(0,0,0),vec,color,label,scale,true,width)).
  }

  set vlex[label]:startupdater to {
    return body:position + vec + vec:normalized * 50000.
  }.

  set vlex[label]:vecupdater to {
    return -vec:normalized * 50000.
  }.

}
  // vecDrawAdd(vecDrawLex, v(0,0,0), v(0,0,0), blue,"targetPos").
  // set vecDrawLex:targetPos:startupdater to {
  //   return body:position + targetPosition + targetPosition:normalized * 50000.
  // }.
  // set vecDrawLex:targetPos:vecupdater to { return -targetPosition:normalized * 50000.}.