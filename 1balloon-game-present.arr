use context starter2024
import image as I
import reactors as R


img2 = I.image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1bCdQQ_qDabtz4TdW9kJWmrxDHxMouoEt")

balloon2 = image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1KcMLdlR44ZtkZstUWQCX3Dcig7YWxA_A")

img1 = image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1L1zB_v1WEd9PJVBmf1Y7RVub_3gJV-x7")

birdleft = image-url("https://code.pyret.org/shared-image-contents?sharedImageId=12khNf5EirtNfi_6jms37_9u6O0itA9SH")

coinz = image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1A1lit04DdpUj6nF_IWDOK_upxFY9EUJt")

birdright = image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1a7jpBu1TKfISx_0HK86JjRU-zQXUtnmA")


######## loading our images ########
balloon = crop(0, 0, 200, 150, scale(0.20, balloon2))
clouds1 = scale(0.10, img1)
clouds2 = scale(0.20, img1)
pin = scale(0.03, img2)
birdl = scale(0.08, birdleft) 
birdr = scale(0.08, birdright)
coin1 = scale(0.05, coinz)
coin2 = scale(0.051, coinz)

######## setting some data structures up to measure world state and position ########
data Posn:
  | posn(x :: Number, y :: Number)
end

data World:
  | world(p :: Posn, birdl :: Posn, birdr :: Posn, c1 :: Posn, c2 :: Posn, co1 :: Posn, co2 :: Posn, f, xmove :: Number, bymove :: Number, cmove :: Number)
end

## setting background up
width = 800
height = 500
blank-scene = I.empty-scene(width, height)

# locations and background
birdl-loc = posn(50, (50 + (random(height - 200))))
birdr-loc = posn(750, (50 + (random(height - 200))))

cloud1-loc = posn(200, 100)
cloud2-loc = posn(650, 350)

coin1-loc = posn(300, 20 + random(height - 50))
coin2-loc = posn(500, 20 + random(height - 50))

sky = I.rectangle(width, height, "solid", "light cyan")
#counter = frame(I.rectangle(75, 50, "solid", "gold"))
counter = frame(I.rectangle(125, 50, "solid", "gold"))

background = I.place-image(counter, 80, 35,
  I.place-image(sky, width / 2, height / 2, blank-scene))


scoreboard = frame(I.rectangle(width / 2, height / 2, "solid", "light green"))

######### moving on tick ##########
key-distance = 4

init-pos = world(posn(400, 0), birdl-loc, birdr-loc, cloud1-loc, cloud2-loc, coin1-loc, coin2-loc, 0, 4, 5, 1)

fun c-y-move(w :: World) -> Number:
  ask:
    | w.f == 0 then: w.cmove
    | otherwise:
      if num-modulo(w.f, 5) == 0:
        w.cmove + 1
      else:
        w.cmove
      end
  end
end

fun balloon-y-move(w :: World) -> Number:
  ask:
    | w.f == 0 then: w.bymove
    | otherwise:
      if num-modulo(w.f, 5) == 0:
        w.bymove + 1
      else:
        w.bymove
      end
  end
end

fun bird-x-move(w :: World) -> Number:
  ask:
    | w.f == 0 then: w.xmove
    | otherwise:
      if num-modulo(w.f, 5) == 0:
        w.xmove + 1
      else:
        w.xmove
      end
  end
end

fun move-balloon-y-on-tick(w :: World) -> World:
  world(posn(w.p.x, w.p.y - w.bymove), 
    w.birdl, 
    w.birdr, 
    w.c1, 
    w.c2, 
    w.co1, 
    w.co2, 
    w.f, 
    bird-x-move(w), 
    balloon-y-move(w), c-y-move(w))
end

fun move-birdl-on-tick(w :: World) -> World:
  world(w.p, 
    posn(w.birdl.x + w.xmove, w.birdl.y), 
    w.birdr,
    w.c1, 
    w.c2, 
    w.co1, 
    w.co2, 
    w.f, 
    bird-x-move(w),
    balloon-y-move(w), c-y-move(w))
end

fun move-birdr-on-tick(w :: World) -> World:
  world(w.p, 
    w.birdl, 
    posn(w.birdr.x - w.xmove, w.birdr.y), 
    w.c1, 
    w.c2, 
    w.co1, 
    w.co2, 
    w.f, 
    bird-x-move(w),
    balloon-y-move(w), c-y-move(w))
end

fun move-cloud1(w :: World) -> World:
  world(w.p, 
    w.birdl, 
    w.birdr,
    posn(w.c1.x, w.c1.y - w.cmove), 
    w.c2, 
    w.co1, 
    w.co2, 
    w.f, 
    bird-x-move(w),
    balloon-y-move(w), c-y-move(w))
end

fun move-cloud2(w :: World) -> World:
  world(w.p, 
    w.birdl, 
    w.birdr,
    w.c1, 
    posn(w.c2.x, w.c2.y - w.cmove), 
    w.co1, 
    w.co2, 
    w.f, 
    bird-x-move(w),
    balloon-y-move(w), c-y-move(w))
end

######## collision ########
fun distance(p1 :: Posn, p2 :: Posn):
  fun squares(n): n * n end
  num-sqrt(squares(p1.x - p2.x) + squares(p1.y - p2.y))
end

fun are-overlapping(w):
  (distance(w.p, w.birdl) < 60) or (distance(w.p, w.birdr) < 60)
end

fun touches-coin1(w):
  distance(w.p, w.co1) < 40
end
fun touches-coin2(w):
  distance(w.p, w.co2) < 40
end

#on tick, coin and wrapping
fun move-wrapping-on-tick(w :: World):
 if touches-coin1(w):
    if w.co1.x == 300:
      world(
        posn(w.p.x, num-modulo(move-balloon-y-on-tick(w).p.y, height)),
        posn(num-modulo(move-birdl-on-tick(w).birdl.x, width), w.birdl.y),
        posn(num-modulo(move-birdr-on-tick(w).birdr.x, width), w.birdr.y),
        posn(w.c1.x, num-modulo(move-cloud1(w).c1.y, height)),
        posn(w.c2.x, num-modulo(move-cloud2(w).c2.y, height)),
        posn(500, num-modulo(w.co1.y + random(height - 50), height)), 
        w.co2,
        w.f + 1, 
        bird-x-move(w),
    balloon-y-move(w), c-y-move(w))
    
    else: world(
        posn(w.p.x, num-modulo(move-balloon-y-on-tick(w).p.y, height)),
        posn(num-modulo(move-birdl-on-tick(w).birdl.x, width), w.birdl.y),
        posn(num-modulo(move-birdr-on-tick(w).birdr.x, width), w.birdr.y),
        posn(w.c1.x, num-modulo(move-cloud1(w).c1.y, height)),
        posn(w.c2.x, num-modulo(move-cloud2(w).c2.y, height)),
        posn(300, num-modulo(w.co1.y + random(height - 50), height)), 
        w.co2,
        w.f + 1, 
        bird-x-move(w),
    balloon-y-move(w), c-y-move(w))
    end
      
  else if touches-coin2(w):
    if w.co2.x == 300:
    world(
      posn(w.p.x, num-modulo(move-balloon-y-on-tick(w).p.y, height)),
      posn(num-modulo(move-birdl-on-tick(w).birdl.x, width), w.birdl.y),
      posn(num-modulo(move-birdr-on-tick(w).birdr.x, width), w.birdr.y),
      posn(w.c1.x, num-modulo(move-cloud1(w).c1.y, height)),
      posn(w.c2.x, num-modulo(move-cloud2(w).c2.y, height)),
      w.co1,
        posn(500, num-modulo(w.co2.y + random(height - 50), height)), 
      w.f + 1, 
        bird-x-move(w),
    balloon-y-move(w), c-y-move(w))
    
    else:
      world(
        posn(w.p.x, num-modulo(move-balloon-y-on-tick(w).p.y, height)),
        posn(num-modulo(move-birdl-on-tick(w).birdl.x, width), w.birdl.y),
        posn(num-modulo(move-birdr-on-tick(w).birdr.x, width), w.birdr.y),
        posn(w.c1.x, num-modulo(move-cloud1(w).c1.y, height)),
        posn(w.c2.x, num-modulo(move-cloud2(w).c2.y, height)),
        w.co1,
        posn(300, num-modulo(w.co2.y + random(height - 50), height)), 
        w.f + 1, 
        bird-x-move(w),
    balloon-y-move(w), c-y-move(w))
    end  
    
  else:
    world(
      posn(w.p.x, num-modulo(move-balloon-y-on-tick(w).p.y, height)),
      posn(num-modulo(move-birdl-on-tick(w).birdl.x, width), w.birdl.y),
      posn(num-modulo(move-birdr-on-tick(w).birdr.x, width), w.birdr.y),
      posn(w.c1.x, num-modulo(move-cloud1(w).c1.y, height)),
      posn(w.c2.x, num-modulo(move-cloud2(w).c2.y, height)),
      w.co1, w.co2,
      w.f, 
      w.xmove, w.bymove, w.cmove)
  end
end 

#gives new position of world and places it on bg
fun place-balloon-xy(w :: World): 
  if are-overlapping(w):
     I.place-image(text("Your Score: " + num-to-string(w.f), 50, "black"),width / 2, height / 2, 
        I.place-image(clouds1, w.c1.x, w.c1.y,
          I.place-image(clouds2, w.c2.x, w.c2.y,
          I.place-image(scoreboard, width / 2, height / 2, 
            sky)))) 

  else:
  I.place-image(balloon, w.p.x, w.p.y,
    I.place-image(birdl, w.birdl.x, w.birdl.y,
      I.place-image(birdr, w.birdr.x, w.birdr.y,
        I.place-image(clouds1, w.c1.x, w.c1.y,
          I.place-image(clouds2, w.c2.x, w.c2.y,
            I.place-image(coin1, w.co1.x, w.co1.y, 
              I.place-image(coin2, w.co2.x, w.co2.y,
                I.place-image(text("coins: " + num-to-string(w.f), 28, "black"), 80, 35,
                  background))))))))
  end
end

######## keys ########
KEY-DISTANCE = 10

fun alter-balloon-xy-on-key(w, key):
  ask:
    | key == "up"   then: world(posn(w.p.x, w.p.y - KEY-DISTANCE), w.birdl, w.birdr, w.c1, w.c2, w.co1, w.co2, w.f ,w.xmove, w.bymove, w.cmove)
    | key == "down" then: world(posn(w.p.x, w.p.y + KEY-DISTANCE), w.birdl, w.birdr, w.c1, w.c2, w.co1, w.co2, w.f,w.xmove, w.bymove, w.cmove)
    | key == "left" then: world(posn(num-modulo(w.p.x - KEY-DISTANCE, width), w.p.y), w.birdl, w.birdr, w.c1, w.c2, w.co1, w.co2, w.f,w.xmove, w.bymove, w.cmove)
    | key == "right" then: world(posn(num-modulo(w.p.x + KEY-DISTANCE, width), w.p.y), w.birdl, w.birdr, w.c1, w.c2, w.co1, w.co2, w.f,w.xmove, w.bymove, w.cmove)
    | otherwise: w
  end
end

### game ends when
fun game-ends(w) block:
  are-overlapping(w)
end

######## calling ########
anim = reactor:
  init: init-pos,
  on-tick: move-wrapping-on-tick,
  on-key: alter-balloon-xy-on-key,
  to-draw: place-balloon-xy,
  stop-when: game-ends,
  close-when-stop: false,
  title: "Balloon Game"
end

R.interact(anim)
