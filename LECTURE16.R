
############################################################
####                                                    ####  
####  NRES 470/670, Lecture 15                          ####
####                                                    ####
####  Kevin Shoemaker                                   #### 
####  University of Nevada, Reno                        ####
####                                                    #### 
############################################################


############################################################
####  Competition                                       ####
############################################################



##### LOTKA VOLTERRA COMPETITION EXAMPLE

## Params

Alpha <- 1.1
Beta <- 0.5
InitN1 <- 100
InitN2 <- 300
K1 <- 1000
K2 <- 450
Rmax1 <- 0.05
Rmax2 <- 0.3
Nyears <- 1000

System <- data.frame(n1 = rep(InitN1,(Nyears+1)),n2 = InitN2)

doYear <- function(prevyear){
  n1 <- prevyear[1] + prevyear[1] * Rmax1 * (1-((prevyear[1]+Alpha*prevyear[2])/(K1)))
  n2 <- prevyear[2] + prevyear[2] * Rmax2 * (1-((prevyear[2]+Beta*prevyear[1])/(K2)))
  return(c(n1,n2))
}

## Do simulation
for(i in 1:(Nyears+1)){
  System[1+i,] <- doYear(System[i,])
}




####
# visualize the initial abundances on the phase plane

plot(1,1,pch="",ylim=c(0,K2*1.5),xlim=c(0,K1*1.5),xlab="species 1",ylab="species 2")
points(System[1,],col="green",pch=20,cex=2)


# and the first 5 years...
plot(1,1,pch="",ylim=c(0,K2*1.5),xlim=c(0,K1*1.5),xlab="species 1",ylab="species 2")
points(System[1:6,],col="green",pch=20,cex=2)


# and many years!
plot(1,1,pch="",ylim=c(0,K2*1.5),xlim=c(0,K1*1.5),xlab="species 1",ylab="species 2")
points(System,col="green",pch=20,cex=2)


##### LOTKA VOLTERRA COMPETITION EXAMPLE #2

## Params

Alpha <- 0.3
Beta <- 0.2
InitN1 <- 100
InitN2 <- 300
K1 <- 1000
K2 <- 450
Rmax1 <- 0.05
Rmax2 <- 0.3
Nyears <- 1000

System <- data.frame(n1 = rep(InitN1,(Nyears+1)),n2 = InitN2)

doYear <- function(prevyear){
  n1 <- prevyear[1] + prevyear[1] * Rmax1 * (1-((prevyear[1]+Alpha*prevyear[2])/(K1)))
  n2 <- prevyear[2] + prevyear[2] * Rmax2 * (1-((prevyear[2]+Beta*prevyear[1])/(K2)))
  return(c(n1,n2))
}

## Do simulation
for(i in 1:(Nyears+1)){
  System[1+i,] <- doYear(System[i,])
}




# visualize on the phase plane

plot(1,1,pch="",ylim=c(0,K2*1.5),xlim=c(0,K1*1.5),xlab="species 1",ylab="species 2")
points(jitter(System[,1],500),jitter(System[,2],500),col="brown",pch=20,cex=0.3)
abline(h=K2,v=K1,col="gray",lwd=2,lty=2)


##### LOTKA VOLTERRA COMPETITION EXAMPLE #3: multiple starting points

## Params


InitN1 <- 1200
InitN2 <- 25
System1 <- data.frame(n1 = rep(InitN1,(Nyears+1)),n2 = InitN2)
## Do simulation
for(i in 1:(Nyears+1)){
  System1[1+i,] <- doYear(System1[i,])
}

InitN1 <- 500
InitN2 <- 100
System2 <- data.frame(n1 = rep(InitN1,(Nyears+1)),n2 = InitN2)
## Do simulation
for(i in 1:(Nyears+1)){
  System2[1+i,] <- doYear(System2[i,])
}


InitN1 <- 800
InitN2 <- 600
System3 <- data.frame(n1 = rep(InitN1,(Nyears+1)),n2 = InitN2)
## Do simulation
for(i in 1:(Nyears+1)){
  System3[1+i,] <- doYear(System3[i,])
}



# visualize on the phase plane

plot(1,1,pch="",ylim=c(0,K2*1.5),xlim=c(0,K1*1.5),xlab="species 1",ylab="species 2")
points(jitter(System[,1],500),jitter(System[,2],500),col="brown",pch=20,cex=0.3)
points(jitter(System1[,1],500),jitter(System1[,2],500),col="green",pch=20,cex=0.3)
points(jitter(System2[,1],500),jitter(System2[,2],500),col="red",pch=20,cex=0.3)
points(jitter(System3[,1],500),jitter(System3[,2],500),col="blue",pch=20,cex=0.3)

abline(h=K2,v=K1,col="gray",lwd=2,lty=2)

## Paul Hurtado code

## Shiny version was based on code from the following page, sourced 20 July 2016. 
## http://grrrraphics.blogspot.com/2013/01/shiny-desolve-and-ggplot-play-nicely.html

#library(shiny)
library(deSolve) 

#######################################################################################
## Functions for pplane actions.

# Modified from the original script pplane.r written by Daniel Kaplan,
# Dept. of Mathematics, Macalester College, kaplan@macalester.edu 

# Modifications by S. Ellner for use in connection with the textbook
# Dynamic Models in Biology by S.P. Ellner and J. Guckenheimer,
# Princeton University Press (2006)  

# Early modifications of SPE's code by Paul Hurtado:
#   * Removed noisy phase arrow placement
#   * Changed the colors of some of the curves
#   * Relace odesolve package dependency with updated package deSolve.
#
# Later modifications by Paul Hurtado:
#   * Overhaul as a shiny app: http://shiny.rstudio.com/gallery/widget-gallery.html 
#      + Modified functions so that all use input functions of the form: fun(x,y,parms)
#
# Missing Features (TTD):
#
#   * A mechanism to "reset" following an equation or parameter change, 
#     that erases all fixed points, S/U manifolds of saddles, trajectories, etc.
#
#   * Better time step size and integration length controls.
#
#   * Allow user defined labels and colors...  E.g. default colors should 
#     match colors from the matlab version of pplane (personal preference!) 
#
#   * Legend on GUI for fixed point symbols (saddle, source, node, etc.)
#
#   * Do these revised functions work as "command line" tools like SPE's version? 
#     If not, go back and implement wrappers so we can have a unified package!
#      + Ultimately, aim for a shiny/GUI version and command line version.
#      + Once that exists, write documentation, put it all in an R package.
#
#   Inspired by pplane (for Matlab) at http://math.rice.edu/~dfield/
#

##########################################################################################
## These functions assume a function of the form 
##    fun <- function(x,y,p) { with(as.list(p), { c(dx,dy) } ) }
## When we need to use fun with deSolve::ode() we must first convert it via this function:
as.ode.func = function(FUN) { return(function(t,y,parms){list(FUN(y[1],y[2],parms))}) }


##########################################################################################
## Functions for drawing 2D state space / vector field / phase plane plots
## Documentation will be coming soon!! :-)

## Split this into phasearrows.calc() and phasearrows.draw() 
phasearrows <- compiler::cmpfun(function(fun,xlims,ylims,resol=25, col='black', add=F,parms=NULL) {
  if (add==F) {
    plot(1,xlim=xlims, ylim=ylims, type='n',xlab="x",ylab="y");
  }
  x <- matrix(seq(xlims[1],xlims[2], length=resol), byrow=T, resol,resol);
  y <- matrix(seq(ylims[1],ylims[2], length=resol),byrow=F, resol, resol);
  npts <- resol*resol;
  # Removed by PJH so drawing phase arrows twice doesn't change the figure...
  #  xspace <- abs(diff(xlims))/(resol*10);
  #  yspace <- abs(diff(ylims))/(resol*10);
  #  x <- x + matrix(runif(npts, -xspace, xspace),resol,resol);
  #  y <- y + matrix(runif(npts, -yspace, yspace),resol,resol);
  z <- fun(x,y,parms);
  z1 <- matrix(z[1:npts], resol, resol);
  z2 <- matrix(z[(npts+1):(2*npts)], resol, resol);
  maxx <- max(abs(z1));
  maxy <- max(abs(z2));
  dt <- min( abs(diff(xlims))/maxx, abs(diff(ylims))/maxy)/resol;
  lens <- sqrt(z1^2 + z2^2);
  lens2 <- lens/max(lens); ## Can this next line be more robust? Change .1 to ???
  arrows(c(x), c(y), c(x+dt*z1/((lens2)+.1)), c(y+dt*z2/((lens2)+.1)),length=.04, col=col);
})

vec.data<<-list()
phasearrows.calc <- compiler::cmpfun(function(fun,xlims,ylims,resol=25,parms=NULL) {
  #if (add==F) { 
  #  plot(1,xlim=xlims, ylim=ylims, type='n',xlab="x",ylab="y");
  #}
  x <- matrix(seq(xlims[1],xlims[2], length=resol), byrow=T, resol,resol);
  y <- matrix(seq(ylims[1],ylims[2], length=resol),byrow=F, resol, resol);
  npts <- resol*resol;
  z <- fun(x,y,parms);
  z1 <- matrix(z[1:npts], resol, resol);
  z2 <- matrix(z[(npts+1):(2*npts)], resol, resol);
  maxx <- max(abs(z1));
  maxy <- max(abs(z2));
  dx <- min( abs(diff(xlims))/maxx, abs(diff(ylims))/maxy)/resol;
  lens <- sqrt(z1^2 + z2^2);
  lens2 <- lens/max(lens); 
  return(list(x,y,z1,z2,lens2,dx)) # save as vec.data
})

phasearrows.draw <- compiler::cmpfun(function(vfdat=vec.data, col="black") {
  x <- vfdat[[1]]
  y <- vfdat[[2]]
  z1<- vfdat[[3]]
  z2<- vfdat[[4]]
  lens2<- vfdat[[5]]
  dx <- vfdat[[6]]
  ## Can this next line be more robust? Change .1 to 1e-6? Change 0.04 to ???
  arrows(c(x), c(y), c(x+dx*z1/((lens2)+.1)), c(y+dx*z2/((lens2)+.1)),length=.04, col=col);
})


## REMOVE THIS OR NOT???
showcontours <- compiler::cmpfun(function(fun,xlims, ylims,resol=250,add=F, colors=c('red', 'blue'),parms=NULL) {
  x <- matrix(seq(xlims[1],xlims[2], length=resol), byrow=F, resol,resol);
  y <- matrix(seq(ylims[1],ylims[2], length=resol),byrow=T, resol, resol);
  npts = resol*resol;
  z <- fun(x,y,parms);
  z1 <- matrix(z[1:npts], resol, resol);
  z2 <- matrix(z[(npts+1):(2*npts)], resol, resol);
  contour(x[,1],y[1,],z1, add=add, col=colors[1]);
  contour(x[,1],y[1,],z2, add=T, col=colors[2]); 
})

##  Split into nullclines.calc() and nullclines.draw()
nullclines <- compiler::cmpfun(function(fun,xlims, ylims, resol=250, add=F,parms=NULL) {
  x <- matrix(seq(xlims[1],xlims[2], length=resol), byrow=F, resol,resol);
  y <- matrix(seq(ylims[1],ylims[2], length=resol),byrow=T, resol, resol);
  npts = resol*resol;
  z <- fun(x,y,parms);
  z1 <- matrix(z[1:npts], resol, resol);
  z2 <- matrix(z[(npts+1):(2*npts)], resol, resol);
  contour(x[,1],y[1,],z1,levels=c(0), drawlabels=F,add=add, col="orange");
  contour(x[,1],y[1,],z2,levels=c(0), drawlabels=F,add=T, col="magenta"); 
  title(main="Orange = x nullcline, Magenta = y nullcline",cex=0.35); 
})

nullclines.data <- list()
nullclines.calc <- compiler::cmpfun(function(fun,xlims,ylims,resol=250,parms=NULL) {
  x <- matrix(seq(xlims[1],xlims[2], length=resol), byrow=F, resol,resol);
  y <- matrix(seq(ylims[1],ylims[2], length=resol),byrow=T, resol, resol);
  npts = resol*resol;
  z <- fun(x,y,parms);
  z1 <- matrix(z[1:npts], resol, resol);
  z2 <- matrix(z[(npts+1):(2*npts)], resol, resol);
  return(list(x,y,z1,z2)) # return nullclines.data
})

nullclines.draw <- compiler::cmpfun(function(ndat=nullclines.data,add=T){
  x <- ndat[[1]]
  y <- ndat[[2]]
  z1<- ndat[[3]]
  z2<- ndat[[4]]
  contour(x[,1],y[1,],z1,levels=c(0), drawlabels=F,add=add, col="orange");
  contour(x[,1],y[1,],z2,levels=c(0), drawlabels=F,add=T, col="magenta"); 
  #title(main="Orange = x nullcline, Magenta = y nullcline",cex=0.35); 
})

## We need something like an array or list for each trajectory, that we can add to.
## BETA VERSION: Don't track time. Add that in later once it all works?
##
## 1. Structure to save curves: traj.data   
traj.data=list() # each element will be an Mx3 matrix like cbind(time,x,y)
## 2. Function to plot them all. Allow ability to pass args to ode() via ...
traj.draw = function(tdat=traj.data,col="blue",lwd=2) {
  #print(unlist(tdat[[1]]))
  for(i in 1:length(tdat)) { 
    lines(tdat[[i]][,2:3], lwd=lwd, col=col)}
}

## 3. grid.calc()    
grid.calc <- compiler::cmpfun(function(fun,xlim,ylim,parms,ngrid,maxtime=50) {
  xvals=seq(xlim[1],xlim[2],length=ngrid); 
  yvals=seq(ylim[1],ylim[2],length=ngrid); 
  ts <- list()
  for(i in 1:ngrid) {
    for(j in 1:ngrid) {
      out1=ode(times=  seq(0,maxtime,length=500),y=c(xvals[i],yvals[j]),func=as.ode.func(fun),parms=parms); 
      out2=ode(times= -seq(0,maxtime,length=500),y=c(xvals[i],yvals[j]),func=as.ode.func(fun),parms=parms); 
      ts[[length(ts)+1]] <- rbind(out2[nrow(out2):2 , ],out1)
    }}
  return(ts)
})

## 4. traj.forward() and traj.backward()    
traj.forward  = compiler::cmpfun(function(x0,fun,parms,maxtime,Tlen=500,...){
  out=ode(times=seq(0,maxtime,length=Tlen),y=c(x0[1],x0[2]),func=as.ode.func(fun),parms=parms,...); 
  return(out);
})

traj.backward = compiler::cmpfun(function(x0,fun,parms,maxtime,Tlen=500,...){
  out=ode(times=seq(0,-maxtime,length=Tlen),y=c(x0[1],x0[2]),func=as.ode.func(fun),parms=parms,...); 
  return(out[nrow(out):1,]);
})

## 5. traj.continue()
traj.continue <- compiler::cmpfun(function(fun, parms, tdat, maxtime, Tlen=500, backward=FALSE, ...){
  if(length(tdat)==0) { cat("WARNING: No trajectories have been calculate yet!\n")}
  out.curr <- tdat[[length(tdat)]]
  if(backward) {
    X0=head(out.curr,1); 
    t0=X0[1];
    x0=X0[-1];
    times=t0+seq(0,-maxtime,length=Tlen); 
    out=ode(times=times,y=x0,func=as.ode.func(fun),parms=parms,...); 
    return(rbind(out[nrow(out):2,],out.curr));
  } else {
    X0=tail(out.curr,1); 
    t0=X0[1]
    x0=X0[-1]
    times=t0+seq(0,maxtime,length=Tlen); 
    out=ode(times=times,y=x0,func=as.ode.func(fun),parms=parms,...); 
    return(rbind(out.curr,out[-1,]));
  }
})

## original grid() function
grid=compiler::cmpfun(function(fun,xlim,ylim,parms,ngrid,maxtime=50,Tlen=500,add=F,color="blue") {
  if (add==F) {
    plot(1,xlim=xlim, ylim=ylim, type='n',xlab="x",ylab="y");
  }
  xvals=seq(xlim[1],xlim[2],length=ngrid); 
  yvals=seq(ylim[1],ylim[2],length=ngrid); 
  for(i in 1:ngrid) {
    for(j in 1:ngrid) {
      out=ode(times=seq(0,maxtime,length=Tlen),y=c(xvals[i],yvals[j]),func=as.ode.func(fun),parms=parms); 
      points(out[,2],out[,3],type="l",lwd=2,col=color);
      out=ode(times=-seq(0,maxtime,length=Tlen),y=c(xvals[i],yvals[j]),func=as.ode.func(fun),parms=parms); 
      points(out[,2],out[,3],type="l",lwd=2,col=color);
    }}
})

# Newton's method to find equilibria of vector field.
# func() must have the same input arguments and returns as for ode/rk4.  
# Inputs: 
#   x0 = intial guess at equilibrium. If x0 is not supplied in the call, 
#        the user chooses it from the current graphics device via locator()
#         and the equilibrium is plotted to the same device. Plotting
#         symbol is closed/open=stable/unstable, circle/triangle=eigenvalues imaginary/real.   
#   tol= Convergence tolerance 
#   niter = Maximum number of iterations
#   inc = finite-difference increment for derivative estimates 
# Coded 5/25/06 by SPE based on Matlab toggle.m by JG 
# MODIFIED 7/2016 by PJH to take functions fun(x,y,parms)

newton=compiler::cmpfun(function(fun,x0=NULL,parms=NULL,tol=1e-16,niter=40,inc=1e-6,plotit=TRUE) {
  x=x0; #initial x  
  if (is.null(x0)) {
    warning("Oops! newton() was called without x0 specified!");#{x = locator(n=1); x=c(x$x,x$y)};
    return(list(x=c(NA,NA,df=matrix(NA,2,2),pch=NA)))
  }
  nx = length(x); # length of state vector
  ######### Newton iteration loop: start  
  for(i in 1:niter){  
    y = as.ode.func(fun)(0,x,parms)[[1]] 
    df = matrix(0,nx,nx); # Compute df
    for(j in 1:nx) {
      #Increment vector for estimating derivative wrt jth coordinate
      v=rep(0,nx); 
      v[j] = inc; 
      df[,j]=  (as.ode.func(fun)(t,x+v,parms)[[1]] - as.ode.func(fun)(t,x-v,parms)[[1]])/(2*inc) 
    }
    if (sum(y^2) < tol){  #check for convergence 
      if(plotit){
        ev=eigen(df)$values; pch1=1+as.numeric(Im(ev[1])!=0); pch2=1+as.numeric(max(Re(ev))<0);
        pchs=matrix( c(2,17,1,16),2,2,byrow=T); 	
        #points(x[1],x[2],type="p",pch=pchs[pch1,pch2],cex=1.5)
      }
      cat("Fixed point (x,y) = ",x,"\n"); 
      cat("Jacobian Df=","\n"); print(df);cat("Eigenvalues","\n"); print(eigen(df)$values)
      return(list(x=x,df=df,pch=pchs[pch1,pch2]))   
    } # end convergence check	
    x = x - solve(df,y) # one more step if needed 
    cat(i, x, "\n") #print out the next iterate 
  }
  ######### Newton iteration loop: end  
  cat("Convergence failed"); 
})

## to draw fixed points 
fixed.points.draw <- compiler::cmpfun(function(FPs) {
  for(i in 1:length(FPs)) { points(FPs[[i]]$x[1], FPs[[i]]$x[2], cex=1.5, type="p",pch=FPs[[i]]$pch)} 
})

manifolds.calc <- compiler::cmpfun(function(fun,parms,FPs,maxtime=250, Tlen=500) {
  ms = list()
  for(i in 1:length(FPs)) { if(!any(is.na(FPs[[i]]$x))) {
  x=FPs[[i]]$x; df=FPs[[i]]$df; V=eigen(df)$vectors; ev=eigen(df)$values; 
  
  if (sign(Re(ev[1])) != -sign(Re(ev[2])) | Im(ev[1]) != 0) {
    # if not a saddle...
    ms[[i]] <- list(S=matrix(NA,nrow=1,ncol=2),U=matrix(NA,nrow=1,ncol=2))
  }else{
    i1=which(Re(ev)>0); i2=which(Re(ev)<0); 
    v1=V[,i1]; v2=V[,i2]; eps=1e-3;  
    out1=ode(y=x+eps*v1,times=seq(0,maxtime,length=Tlen),func=as.ode.func(fun),parms=parms); 
    out2=ode(y=x-eps*v1,times=seq(0,maxtime,length=Tlen),func=as.ode.func(fun),parms=parms); 
    out3=ode(y=x+eps*v2,times=-seq(0,maxtime,length=Tlen),func=as.ode.func(fun),parms=parms); 
    out4=ode(y=x-eps*v2,times=-seq(0,maxtime,length=Tlen),func=as.ode.func(fun),parms=parms); 
    
    S = rbind(out3,out4[1,]*NA,out4)[,-1]
    U = rbind(out1,out2[1,]*NA,out2)[,-1]
    
    ms[[i]] <- list(S=S,U=U)
  }} else { # if x[1] is NA...
  ms[[i]] <- list(S=matrix(NA,nrow=1,ncol=2),U=matrix(NA,nrow=1,ncol=2))
  }
  }
 return(ms) 
})

manifolds.draw=compiler::cmpfun(function(ms) {
  for(i in 1:length(ms)){
    S=ms[[i]]$S
    U=ms[[i]]$U
    title(sub="Black=stable manifold, Red=unstable manifold"); 
    points(S[,1],S[,2],type="l",lwd=2,col="black");
    points(U[,1],U[,2],type="l",lwd=2,col="red");
  }
})
    
# Compute Jacobian of a planar vector field at a point (x,y),
# either input or chosen with locator().
jacobianAtXY <- compiler::cmpfun(function(fun,x=NULL, y=NULL,inc=1e-7){
  if (is.null(x)|is.null(y)) {
    x0 <- locator(n=1); x <- x0$x; y <- x0$y;  
  }
  foo <- fun(x,y); h = inc; 
  foox <- fun(x+h,y); fooy <- fun(x,y+h);
  A <- (foox[1] - foo[1])/h;
  B <- (fooy[1] - foo[1])/h;
  C <- (foox[2] - foo[2])/h;
  D <- (fooy[2] - foo[2])/h;
  return(matrix( c(A,B,C,D ),2,2,byrow=T))
})



##########
# Visualize phase plane with arrows!
##########

#######################################################################################
## SPECIFY MODEL AND INITIALIZE
#
## toggle switch function for phase arrow and nullcline plotting 

toggle = compiler::cmpfun(function(u,v,parms) {
  c( u*parms[1]*(1-(u+(parms[2]*v))/parms[3]), v*parms[4]*(1-(v+(parms[5]*u))/parms[6]) )
})

fun=toggle ## Our generic name for the system of equations to look at! ;-)
#
## toggle switch function for computing solution trajectories with deSolve::ode()

#Toggle = as.ode.func(toggle)
#
## parameter values?

Rmax1 <- 0.05
Alpha <- 0.3
K1 <- 1000
Rmax2 <- 0.3
Beta <- 0.2
K2 <- 450

parms=c(Rmax1,Alpha,K1,Rmax2,Beta,K2)

# toggle(100,100,parms)

xlim = c(5,2000)
ylim = c(5,1000)
new <- phasearrows.calc(toggle,xlim,ylim,resol=25,parms=parms)

plot(1,1,pch="",xlim=xlim,ylim=ylim,xlab="N1",ylab="N2")
phasearrows.draw(new)

#
## END MODEL SPECIFICATION AND INITIALIZATION
#######################################################################################


#### example with phase-plane arrows

plot(1,1,pch="",xlim=xlim,ylim=ylim,xlab="N1",ylab="N2")
phasearrows.draw(new)
abline(K1/Alpha,-(K1/Alpha)/K1,col="red",lwd=3)   # species 1
abline(K2,-K2/(K2/Beta),col="blue",lwd=3)   # species 1


##########
# Another example
##########

Rmax1 <- 0.2
Alpha <- 1.1
K1 <- 1000
Rmax2 <- 0.2
Beta <- 0.9
K2 <- 500

parms=c(Rmax1,Alpha,K1,Rmax2,Beta,K2)

# toggle(100,100,parms)

xlim = c(5,1500)
ylim = c(5,1000)
new <- phasearrows.calc(toggle,xlim,ylim,resol=25,parms=parms)

plot(1,1,pch="",xlim=xlim,ylim=ylim,xlab="N1",ylab="N2")
phasearrows.draw(new)
abline(K1/Alpha,-(K1/Alpha)/K1,col="red",lwd=3)   # species 1
abline(K2,-K2/(K2/Beta),col="blue",lwd=3)   # species 2

#########
# And another example!
#########

Rmax1 <- 0.5
Alpha <- 1.05
K1 <- 890
Rmax2 <- 0.2
Beta <- 0.5
K2 <- 890

parms=c(Rmax1,Alpha,K1,Rmax2,Beta,K2)

# toggle(100,100,parms)

xlim = c(5,1500)
ylim = c(5,1000)
new <- phasearrows.calc(toggle,xlim,ylim,resol=25,parms=parms)

plot(1,1,pch="",xlim=xlim,ylim=ylim,xlab="N1",ylab="N2")
phasearrows.draw(new)
abline(K1/Alpha,-(K1/Alpha)/K1,col="red",lwd=3)   # species 1
abline(K2,-K2/(K2/Beta),col="blue",lwd=3)   # species 2


########
# And another!
#########

Alpha <- 0.3
Beta <- 0.2
K1 <- 1000
K2 <- 450
Rmax1 <- 0.05
Rmax2 <- 0.3
Nyears <- 1000
ylim=c(0,K2*1.5)
xlim=c(0,K1*1.5)
plot(1,1,pch="",ylim=ylim,xlim=xlim,xlab="species 1",ylab="species 2")
points(jitter(System[,1],500),jitter(System[,2],500),col="brown",pch=20,cex=0.4)
points(jitter(System1[,1],500),jitter(System1[,2],500),col="green",pch=20,cex=0.4)
points(jitter(System2[,1],500),jitter(System2[,2],500),col="red",pch=20,cex=0.4)
points(jitter(System3[,1],500),jitter(System3[,2],500),col="blue",pch=20,cex=0.4)

parms=c(Rmax1,Alpha,K1,Rmax2,Beta,K2)
xlim = c(5,1500)
ylim = c(5,1000)
new <- phasearrows.calc(toggle,xlim,ylim,resol=15,parms=parms)
phasearrows.draw(new)
abline(h=K2,v=K1,col="gray",lwd=2,lty=2)
abline(K1/Alpha,-(K1/Alpha)/K1,col="red",lwd=2)   # species 1
abline(K2,-K2/(K2/Beta),col="blue",lwd=2)   # species 2


########
# And finally...
########

Rmax1 <- 0.2
Alpha <- 1.5
K1 <- 1000
Rmax2 <- 0.2
Beta <- 2
K2 <- 1500

parms=c(Rmax1,Alpha,K1,Rmax2,Beta,K2)

# toggle(100,100,parms)

xlim = c(5,1500)
ylim = c(5,1000)
new <- phasearrows.calc(toggle,xlim,ylim,resol=25,parms=parms)

plot(1,1,pch="",xlim=xlim,ylim=ylim,xlab="N1",ylab="N2")
phasearrows.draw(new)
abline(K1/Alpha,-(K1/Alpha)/K1,col="red",lwd=3)   # species 1
abline(K2,-K2/(K2/Beta),col="blue",lwd=3)   # species 2

