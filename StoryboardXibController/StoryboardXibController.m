//
//  StoryboardXibController.m
//  CodecademyMobile
//
//  Created by Ian Grossberg on 3/6/14.
//  Copyright (c) 2014 Codecademy. All rights reserved.
//

#import "StoryboardXibController.h"

@interface StoryboardXibController ()

@property (strong, readwrite) NSTimer *containedViewDidLoadCheck; //HACK

@property (strong, readwrite) UIStoryboardSegue *segue;
@property (strong, readwrite) id segueInfo;

@end

@implementation StoryboardXibController

- (void)destinationPrepareForSegue:(UIStoryboardSegue *)segue info:(id)info
{
    if ( [segue.destinationViewController isKindOfClass:[StoryboardXibController class] ] )
    {
        StoryboardXibController *destinationController = segue.destinationViewController;
        destinationController.segue = segue;
        destinationController.segueInfo = info;
    }
}

@synthesize containedController = _containedController;

-( void )setValue:( id )value forUndefinedKey:( NSString* )key
{
    NSString *error = [NSString stringWithFormat:@"Unable to set value %@ for member %@ on object %p of type %@, member does not exist",
                       value,
                       key,
                       self,
                       [self class] ];
    // block iOS' default exception behavior
#ifdef NSLogError
    NSLogError(@"%@", error);
#else
    NSLog(@"Error: %@", error);
#endif
}

- (void)createSubViewController
{
    Class screenControllerClass;
    if (self.screenControllerClass)
    {
        screenControllerClass = NSClassFromString(self.screenControllerClass);
    }
    
    NSBundle *fromBundle;
    if (self.nibBundleName)
    {
        NSString *nibBundlePath = [NSString stringWithFormat:@"Frameworks/%@", self.nibBundleName];
        
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:nibBundlePath withExtension:@"framework"];
        if (bundleURL)
        {
            fromBundle = [NSBundle bundleWithURL:bundleURL];
        } else
        {
            NSString *error = [NSString stringWithFormat:@"Unable to find bundle with the name %@", self.nibBundleName];
#ifdef NSLogError
            NSLogError(@"%@", error);
#else
            NSLog(@"Error: %@", error);
#endif
        }
    }
    
    if (!fromBundle)
    {
        fromBundle = [NSBundle mainBundle];
    }
    
    // TODO: report invalid class or nib file not found, each explicitly
    if ( [screenControllerClass isSubclassOfClass:[UIViewController class] ] && self.screenNib)
    {
        _containedController = [ [screenControllerClass alloc] initWithNibName:self.screenNib bundle:fromBundle];
        [self addChildViewController:self.containedController];

        // yes, getters should not be used for side effects UIKit, but why you gotta only start loading when I do??
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value" // not working
        self.containedController.view;
#pragma cland diagnostic pop

        [self checkContainedViewDidLoad];
    } else
    {
        NSString *error = [NSString stringWithFormat:@"Error with screen controller class %@ and screen nib %@", self.screenControllerClass, self.screenNib];
#ifdef NSLogError
        NSLogError(@"%@", error);
#else
        NSLog(@"Error: %@", error);
#endif
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createSubViewController];
}

- (BOOL)checkContainedViewDidLoad
{
    if (self.containedController.isViewLoaded)
    {
        self.containedViewDidLoadCheck = nil;
        
        UIView *containedView = self.containedController.view;
        containedView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:containedView];
        
        [self setupContainedViewConstraints];
        
        if ( [self.containedController conformsToProtocol:@protocol(StoryboardXibContainedController) ] )
        {
            id<StoryboardXibContainedController> protocol = (id<StoryboardXibContainedController>)self.containedController;
            if ( [protocol respondsToSelector:@selector(storyboardXibLoadedBy:) ] )
            {
                [protocol storyboardXibLoadedBy:self];
            }
        }
        
        if (self.segueInfo != nil && [self.containedController conformsToProtocol:@protocol(SegueingInfoProtocol) ] )
        {
            id<SegueingInfoProtocol> protocol = (id<SegueingInfoProtocol>)self.containedController;
            if ( [protocol respondsToSelector:@selector(destinationPrepareForSegue:info:) ] )
            {
                [protocol destinationPrepareForSegue:self.segue info:self.segueInfo];
            }
        }

        self.segue = nil;
        self.segueInfo = nil;

        if (self.containedControllerLoadedHandler)
        {
            self.containedControllerLoadedHandler(self);
        }

    } else
    {
        self.containedViewDidLoadCheck = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(checkContainedViewDidLoad) userInfo:nil repeats:NO];
        
        NSString *verboseLog = [NSString stringWithFormat:@"Waiting for storyboard xib controller's %@ and screen nib %@ to load", self.screenControllerClass, self.screenNib];
#ifdef NSLogVerbose
        NSLogVerbose(@"%@", verboseLog);
#else
        NSLog(@"Verbose: %@", verboseLog);
#endif
    }
    
    return self.containedController.isViewLoaded;
}

- (void)setupContainedViewConstraints
{
    UIView *containedView = self.containedController.view;
    
    NSLayoutConstraint *containedViewTopLayoutContraint;
    if (self.alignToTopLayoutGuide)
    {
        containedViewTopLayoutContraint = [NSLayoutConstraint constraintWithItem:containedView
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.topLayoutGuide
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0f
                                                                        constant:0];
    } else
    {
        containedViewTopLayoutContraint = [NSLayoutConstraint constraintWithItem:containedView
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0f
                                                                        constant:0];
    }
    [self.view addConstraint:containedViewTopLayoutContraint];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containedView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0f
                                                           constant:0.0] ];
    
    NSLayoutConstraint *containedViewBottomLayoutContraint;
    if (self.alignToBottomLayoutGuide)
    {
        containedViewBottomLayoutContraint = [NSLayoutConstraint constraintWithItem:containedView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomLayoutGuide
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0f
                                                                        constant:0];
    } else
    {
        containedViewBottomLayoutContraint = [NSLayoutConstraint constraintWithItem:containedView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0f
                                                                        constant:0];
    }
    [self.view addConstraint:containedViewBottomLayoutContraint];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containedView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0f
                                                           constant:0.0] ];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    [self destinationPrepareForSegue:segue info:sender];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol;
{
    BOOL result = [super conformsToProtocol:aProtocol];
    if (!result)
    {
        result = [self.containedController conformsToProtocol:aProtocol];
    }
    return result;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL result = [super respondsToSelector:aSelector];
    if (!result)
    {
        result = [self.containedController respondsToSelector:aSelector];
    }
    return result;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // here we default to the contained controller because forwardInvocation: is only called when we can't respond ourselves
    if ( [self.containedController respondsToSelector:anInvocation.selector] )
    {
        [anInvocation invokeWithTarget:self.containedController];
    } else
    {
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature && [self.containedController respondsToSelector:selector] )
    {
        signature = [self.containedController methodSignatureForSelector:selector];
    }
    return signature;
}

@end
