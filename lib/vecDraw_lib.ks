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