package Minikin.Objects.Enemies 
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import Minikin.Global.ImageManager;
	import net.flashpunk.FP;
	import Minikin.Global.GameDetails;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Entity;
	import Minikin.Objects.Sword;
	
	/**
	 * ...
	 * @author Nick Heckman
	 */
	public class Bandit extends Enemy
	{
		public var mIsJumping:Boolean;
		public var mJumpTimer:Timer;
		public var mIsHurt:Boolean;
		
		public function Bandit() 
		{
			mSprite = new Spritemap(ImageManager.IMG_BANDIT, 24, 24);
			mSprite.add("Stand", [0]);
			mSprite.add("Jump", [0]);
			
			graphic = mSprite;
			
			mDamage = 3;
			mHealth = 20;
			
			mJumpTimer = new Timer(1000 + Math.random() * 1000);
			mJumpTimer.addEventListener(TimerEvent.TIMER, Jump);
			mJumpTimer.start();
			
			mSprite.centerOO();
			setHitbox(16, 16, 8, 5);
			
		}
		
		override public function update():void 
		{
			super.update();
			
			if (collide("Level", x + mVelocity.x * FP.elapsed, y))
			{
				mVelocity.x = 0;
			}
			
			
			
			x += mVelocity.x*FP.elapsed;
			y += mVelocity.y * FP.elapsed;
			
			if (mVelocity.x < 0) mSprite.scaleX = -1;
			if (mVelocity.x > 0) mSprite.scaleX = 1;
			
			var other:Entity = collide("Level", x, y);
			if (collide("Level", x, y)) {
				trace("Collided");
				while (collideWith(other, x, y))
				{
					y += -FP.sign(mVelocity.y);
				}
				if (mVelocity.y > 0)
				{
					mIsHurt = false;
					mIsJumping = false;
					mSprite.alpha = 1.0;
					mSprite.play("Stand");
				}
				mVelocity.y = 0;
				mVelocity.x = 0;
			}
			else
			{
				if (!collide("Level", x, y + 1))
				{
					mVelocity.y += 2000 * FP.elapsed;
				}
			}
			
			other = collide("Platform", x, y+1);
			if (mVelocity.y > 0 && other && other.y+10 > y + 6)
			{
				mIsHurt = false;
				mIsJumping = false;
				mSprite.alpha = 1.0;
				mSprite.play("Stand");
				while (collideWith(other, x, y))
				{
					y += -FP.sign(mVelocity.y);
				}
				mVelocity.y = 0;
				mVelocity.x = 0;
			}
			
			var otherSword:Sword = collide("Sword", x, y) as Sword;
			if (otherSword)
			{
				mVelocity.x = FP.sign(x - otherSword.x) * 200;
				mVelocity.y = -100;
				if (mIsHurt == false)
				{
					mHealth -= otherSword.Damage();
					mIsHurt = true;
					mSprite.alpha = 0.5;
					if (mHealth <= 0)
					{
						FP.world.remove(this);
					}
				}
			}
		}
		
		public function Jump(e:Event):void
		{
			if (mIsJumping == false)
			{
				mJumpTimer.delay = 1000 + Math.random() * 1000;
				mJumpTimer.reset();
				mJumpTimer.start();
				
				mSprite.play("Jump");
				
				mIsJumping = true;
				mVelocity.y = -500;
				mVelocity.x = FP.sign(GameDetails.GetInstance().mPlayer.x - x) * 300 * Math.random();
			}
		}
		
		override public function CleanUp():void 
		{
			mJumpTimer.stop();
			mJumpTimer = null;
			
			super.CleanUp();
		}
	}

}