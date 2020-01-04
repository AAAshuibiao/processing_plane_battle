class Plane{
  
  public boolean isActive;
  public boolean isPlayer;
  public int x;
  public int y;
  public int dx;
  public int dy;
  public boolean isExplode;
  public int fireCount;
  public int explodeCount;
  
  public Plane(){
    isActive = false;
    isExplode = false;
  }
  
  public void update(){
    if( isActive ){
      if( !isExplode ){
        checkKilled();
        checkFire();
        blit();
        if( isPlayer ){
          setPositionToMouse();
        }
        else{
          updatePositionByVelocity();
        }
      }
      else{
        drawExplode();
      }
    }
  }
  
  public void blit(){
    if( isPlayer ){
      fill(0, 255, 0);
      triangle(x, y-20, x-20, y+20, x+20, y+20);
    }
    else{
      fill(255, 0, 0);
      triangle(x-20, y-20, x+20, y-20, x, y+20);
    }
  }
  
  public void active(int ini_x, int ini_y, int ini_dx, int ini_dy){
    isActive = true;
    isExplode = false;
    x = ini_x;
    y = ini_y;
    dx = ini_dx;
    dy = ini_dy;
  }
  
  public void updatePositionByVelocity(){
    x += dx;
    y += dy;
  }
  
  public void setPositionToMouse(){
    int new_x = mouseX;
    int new_y = mouseY;
    dx = new_x - x;
    dy = new_y - y;
    x = new_x;
    y = new_y;
  }
  
  public void checkKilled(){
    if( x < 0 || x > 500 || y < 0 || y > 500 ){
      isActive = false;
    }
    int x_diff;
    int y_diff;
    for(int i=0; i<1024; i++){
      x_diff = x - bullets[i].x;
      y_diff = y - bullets[i].y;
      if( x_diff > -15 && x_diff < 15 && y_diff > -15 && y_diff < 15 && bullets[i].isPlayerBullet != isPlayer){
        if( isPlayer ){
          displayScoreInfo(true);
        }
        else{
          if(playerPlane.isActive && (!playerPlane.isExplode) ){
            score++;
            displayScoreInfo(false);
          }
        }
        explode();
      }
    }
  }
  
  public void checkFire(){
    if( fireCount == 0 ){
      if( isPlayer ){
        newBullet(x, y-10, 0, -10, true);
        fireCount = 5;
      }
      else{
        newBullet(x, y+10, dx, dy+10, false);
        fireCount = 25;
      }
    }
    else{
      fireCount--;
    }
  }
  
  public void explode(){
    isExplode = true;
    explodeCount = 10;
  }
  
  public void drawExplode(){
    if( explodeCount!=0 ){
      fill(explodeCount*20 , explodeCount*20 ,0);
      ellipse(x, y, 40, 40);
      explodeCount--;
    }
    else{
      isActive = false;
    }
  }
  
}

class Bullet{
  
  public boolean isActive;
  public int x;
  public int y;
  public int dx;
  public int dy;
  public boolean isPlayerBullet;
  
  public Bullet(){
    isActive = false;
  }
  
  public void update(){
    if( isActive ){
      checkKilled();
      updatePositionByVelocity();
      blit();
    }
  }
  
  public void blit(){
    if( isPlayerBullet ){
      fill(0 ,255 ,0);
    }
    else{
      fill(255, 0, 0);
    }
    rect(x-2, y-2, 4, 4);
  }
  
  public void active(int ini_x, int ini_y, int ini_dx, int ini_dy, boolean isP){
    isActive = true;
    x = ini_x;
    y = ini_y;
    dx = ini_dx;
    dy = ini_dy;
    isPlayerBullet = isP;
  }
  
  public void updatePositionByVelocity(){
    x += dx;
    y += dy;
  }
  
  public void checkKilled(){
    if( x < 0 || x > 500 || y < 0 || y > 500 ){
      isActive = false;
    }
  }
  
}

void drawBackground(){
  fill(0, 0, 0);
  rect(0, 0, 500, 500);
}

void updatePlanes(){
  for(int i=0; i<64; i++){
    planes[i].update();
  }
}

void updateBullets(){
  for(int i=0; i<1024; i++){
    bullets[i].update();
  }
}

void newPlane(int x, int y, int dx, int dy){
  for(int i = 1; i<64; i++){
    if( !planes[i].isActive ){
      planes[i].active(x, y, dx, dy);
      return;
    }
  }
}

void newBullet(int x, int y, int dx, int dy, boolean isP){
  for(int i = 0; i<1024; i++){
    if( !bullets[i].isActive ){
      bullets[i].active(x, y, dx, dy, isP);
      return;
    }
  }
}

void checkNewPlane(){
  if( newPlaneCount == 0 ){
    int x = (int)random(401) + 50;
    int y = 0;
    int dx = (int)random(3) - 1;
    int dy = (int)random(3) + 1;
    newPlane(x, y, dx, dy);
    if( score<50 ){
      newPlaneCount = 50 - score;
    }
    else{
      newPlaneCount = 1;
    }
  }
  else{
    newPlaneCount--;
  }
}

void displayScoreInfo(boolean isFinal){
  if( !isFinal ){
    print("your current score is:");
  }
  else{
    print("your final score is:");
  }
  print(score);
  println();
}

Plane playerPlane = new Plane();
public Plane[] planes = new Plane[64];
public Bullet[] bullets = new Bullet[1024];

void setup(){
  println("click mouse to start");
  size(500,500);
  
  playerPlane.isPlayer = true;
  planes[0] = playerPlane;
  
  for(int i=1; i<64; i++){
    planes[i] = new Plane();
  }
  
  for(int i=0; i<1024; i++){
    bullets[i] = new Bullet();
  }
}

public int score = 0;
public int newPlaneCount = 100;
public int loopStartTime;

void draw(){
  loopStartTime = millis();
  
  drawBackground();
  updatePlanes();
  updateBullets();
  
  if( playerPlane.isActive ){
    checkNewPlane();
  }
  
  if( mousePressed ){
    score = 0;
    newPlaneCount = 100;
    playerPlane.active(mouseX, mouseY, 0, 0);
  }
  
  while( millis() - loopStartTime > 33 );
}
