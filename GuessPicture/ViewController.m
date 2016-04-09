//
//  ViewController.m
//  GuessPicture
//
//  Created by HuberySun on 16/3/28.
//  Copyright © 2016年 HuberySun. All rights reserved.
//

#import "ViewController.h"
#import "Question.h"
#import "MBProgressHUD.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *LblIndex;
@property (strong, nonatomic) IBOutlet UILabel *lblDesc;
@property (strong, nonatomic) IBOutlet UIButton *btnMoney;
@property (strong, nonatomic) IBOutlet UIButton *btnImg;
@property (strong, nonatomic) IBOutlet UIView *viewAnswer;
@property (strong, nonatomic) IBOutlet UIView *viewOptions;
@property (strong, nonatomic) IBOutlet UIButton *btnNext;

@property(nonatomic ,strong)NSArray *questions;
@property(nonatomic, assign)int index;

@property(nonatomic, strong)UIView *backgroundView;
@property(nonatomic, strong)Question *currentQuestion;
@property(nonatomic, assign)CGRect originFrame;
@end

@implementation ViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.index=-1;
    [self nextQuestion];
}

- (NSArray *)questions{
    if (!_questions) {
        NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil];
        NSArray *dics=[NSArray arrayWithContentsOfFile:plistPath];
        NSMutableArray *questions=[NSMutableArray array];
        for (NSDictionary *dic in dics) {
            Question *question=[Question questionWithDic:dic];
            [questions addObject:question];
        }
        _questions=[NSArray arrayWithArray:questions];
    }
    return _questions;
}

- (IBAction)tip:(id)sender {
    for (int i=0; i<self.viewAnswer.subviews.count; i++) {
        UIButton *btn=[self.viewAnswer.subviews objectAtIndex:i];
        if (![btn currentTitle]) {
            //扣除50分,提示答案
            NSInteger currentGrade=[[self.btnMoney currentTitle] integerValue];
            if (currentGrade<50) {
                MBProgressHUD *gradeLackHUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
                gradeLackHUD.mode=MBProgressHUDModeText;
                gradeLackHUD.labelText=@"余额不足，请充值";
                gradeLackHUD.removeFromSuperViewOnHide=YES;
                [gradeLackHUD performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
            }else{
                NSInteger newGrade=currentGrade-50;
                [self.btnMoney setTitle:[NSString stringWithFormat:@"%ld",newGrade] forState:UIControlStateNormal];
                
                //遍历选项按钮，获取与答案相同且没有被隐藏的按钮
                NSString *tip=[self.currentQuestion.answer substringWithRange:NSMakeRange(i, 1)];
                for (UIButton *btn in self.viewOptions.subviews) {
                    if ([[btn currentTitle] isEqual:tip] && !btn.hidden) {
                        [self optionClick:btn];
                    }
                }
            }
            
            break;
        }
    }
}

- (IBAction)avatarClick:(id)sender {
    if (self.backgroundView) {
        [self smallImage];
    }else{
        [self bigImage];
    }
}

- (IBAction)enlarge:(id)sender {
    [self bigImage];
}

- (void)bigImage{
    UIView *backgroundView=[[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha=0;
    [self.view addSubview:backgroundView];
    self.backgroundView=backgroundView;
     [self.view bringSubviewToFront:self.btnImg];
    
    CGFloat imgW=self.view.bounds.size.width;
    CGFloat imgY=(self.view.bounds.size.height-imgW)/2.0;
    CGRect bigFrame=CGRectMake(0, imgY, imgW, imgW);
    self.originFrame=self.btnImg.frame;
    
    [UIView animateWithDuration:1 animations:^{
         self.backgroundView.alpha=0.5;
        [self.btnImg setFrame:bigFrame];
    }];
}

- (void)smallImage{
    [UIView animateWithDuration:1 animations:^{
        [self.btnImg setFrame:self.originFrame];
        self.backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView=nil;
    }];
}

- (IBAction)next:(id)sender {
    [self nextQuestion];
}

- (void)nextQuestion{
    self.index++;
    [self.viewAnswer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.viewOptions.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.viewAnswer.userInteractionEnabled=YES;
    self.viewOptions.userInteractionEnabled=YES;
    
    Question *question=[self.questions objectAtIndex:self.index];
    self.currentQuestion=question;
    self.LblIndex.text=[NSString stringWithFormat:@"%d/%ld",self.index+1,self.questions.count];
    self.lblDesc.text=question.title;
    [self.btnImg setImage:[UIImage imageNamed:question.icon] forState:UIControlStateNormal];
    
    NSUInteger wordsCount=question.answer.length;
    CGFloat answerW=44;
    CGFloat marginX=(self.viewAnswer.frame.size.width-answerW*wordsCount-(wordsCount-1)*10)/2.0;
    for (int i=0; i<wordsCount; i++) {
        CGFloat answerX=marginX+(answerW+10)*i;
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(answerX, 0, answerW, answerW)];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewAnswer addSubview:btn];
    }
    
    int numberOfBtEachRow=7;
    CGFloat optionW=44;
    CGFloat optionX=(self.viewOptions.bounds.size.width-optionW*numberOfBtEachRow)/(numberOfBtEachRow+1);
    CGFloat optionY=5;
    NSUInteger optionsCount=question.options.count;
    for (int i=0; i<optionsCount; i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        int row=i/numberOfBtEachRow;
        int column=i%numberOfBtEachRow;
        CGFloat btnX=optionX+(optionW+optionX)*column;
        CGFloat btnY=optionY+(optionW+optionY)*row;
        [btn setFrame:CGRectMake(btnX,btnY, optionW, optionW)];
        btn.tag=i;
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:question.options[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewOptions addSubview:btn];
        
    }
    
    
    self.btnNext.enabled=(self.index!=(self.questions.count-1));
}

- (void)optionClick:(UIButton *)sender{
    sender.hidden=YES;
    
    //获取第一个 文字内容为空的答案按钮，把选项按钮的tag和文字 赋值给答案按钮
    NSUInteger subviewCount=self.viewAnswer.subviews.count;
    for (UIButton *btn in self.viewAnswer.subviews) {
        if (![btn currentTitle]) {
            [btn setTitle:[sender currentTitle] forState:UIControlStateNormal];
            btn.tag=sender.tag;
            break;
        }
    }
    
    //判断用户是否已经填好了所有的按钮答案
    NSUInteger i;
    for (i=0;i<subviewCount;i++) {
        UIButton *btn=[self.viewAnswer.subviews objectAtIndex:i];
        if (![btn currentTitle]) {
            break;
        }
    }
    if (i==subviewCount) {
        self.viewOptions.userInteractionEnabled=NO;
        
        NSMutableString *answers=[NSMutableString string];
        //拼接答案按钮的文字，获得用户选择的答案
        for (UIButton *btn in self.viewAnswer.subviews) {
            if ([btn currentTitle]) {
                [answers appendString:[btn currentTitle]];
            }
        }
        //如果和正确答案相同，就改变按钮文字为绿色，否则为红色
        if ([[NSString stringWithString:answers] isEqualToString:self.currentQuestion.answer]) {
            for (UIButton *btn in self.viewAnswer.subviews) {
                [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            }
            
            //奖励100分
            NSInteger grade=[[self.btnMoney currentTitle] integerValue]+100;
            [self.btnMoney setTitle:[NSString stringWithFormat:@"%ld",grade] forState:UIControlStateNormal];
            
            //一秒之后，切换到下一题
            [self performSelector:@selector(changeQuestion) withObject:nil afterDelay:1]; 
        }else{
            for (UIButton *btn in self.viewAnswer.subviews) {
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
    }
    
    
    
}

- (void)changeQuestion{
    //过一秒钟 自动跳到下一题 或者回到第一题
    if (self.index==self.questions.count-1) {
        self.index=-1;
        [self nextQuestion];
    }else{
        [self nextQuestion];
    }
}

- (void)answerClick:(UIButton *)sender{
    if (![sender currentTitle]) {
        return;
    }
    
    for (UIButton *btn in self.viewOptions.subviews) {
        if (btn.tag==sender.tag) {
            [sender setTitle:nil forState:UIControlStateNormal];
            btn.hidden=NO;
            break;
        }
    }
    
    for (UIButton *btn in self.viewAnswer.subviews) {
        if (![btn currentTitle]) {
            self.viewOptions.userInteractionEnabled=YES;
            
            //恢复答案按钮的正常颜色
            for (UIButton *btn in self.viewAnswer.subviews) {
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            break;
        }
    }
}
@end
