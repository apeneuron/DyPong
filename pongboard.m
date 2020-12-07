classdef pongboard < handle
    properties
        L = 128;                                
        W = 256;                                
        B = 10;                                
        ErrN = 0;
        
        PW = 14;                            
        PV = 10;                          
        V = 7;
        
        thMAX = 60;
        thrMAX;
        C = 0;
        
        endscore = 21;
        roundflag = true;                  
        totalflag = true;
        positive = true;    
        
        P = [0,0];
        SCORE = [0,0];
        board = [];
        
        PAD_AGENT = 0;
        PAD_OP = 0;
        theta = 0;
            
        idx, Vb, predf, distf, nstring, estring;
    end
    
    methods
        function obj = pongboard(thrMAX,predf,idx,nstr)
            obj.thrMAX = thrMAX;
            obj.predf = predf;
            obj.distf = round(predf*obj.L);
            obj.idx = idx;
            
            obj.Vb = [obj.V,0];
            obj.nstring = nstr;
            obj.estring = [' (' num2str(obj.thrMAX) '-*' ...
                num2str(obj.predf) ')'];
            
            tic;
        end
        
        function npad = padb(obj,pad,action)
            npad = pad+obj.PV*action;
            npad = max(min(npad,obj.L),-obj.L);
        end
        
        function upperb(obj)
            yt = obj.P(2)-obj.L;
            lt = obj.V*yt/abs(obj.Vb(2));
            obj.P = [obj.P(1)-lt*cosd(obj.theta),obj.L];
            
            while true
                thr = randi([-obj.thrMAX, obj.thrMAX]);
                ntheta = thr-obj.theta;
                ntheta = mod(ntheta+180,360)-180;
                cond = (sign(ntheta)~=sign(obj.theta));
                
                if cond
                    break;
                end
            end
            
            obj.theta = ntheta;
            R = [cosd(obj.theta) -sind(obj.theta); sind(obj.theta) cosd(obj.theta)];
            obj.P = obj.P+(R*[lt,0]')';
            obj.Vb = (R*[obj.V;0])';
        end
        
        function lowerb(obj)
            yt = -obj.L-obj.P(2);
            lt = obj.V*yt/abs(obj.Vb(2));
            obj.P = [obj.P(1)-lt*cosd(obj.theta),-obj.L];
            obj.Vb(2) = -obj.Vb(2);
            
            while true
                thr = randi([-obj.thrMAX, obj.thrMAX]);
                ntheta = thr-obj.theta;
                ntheta = mod(ntheta+180,360)-180;
                cond = (sign(ntheta)~=sign(obj.theta));
                
                if cond
                    break;
                end
            end
            
            obj.theta = ntheta;
            R = [cosd(obj.theta) -sind(obj.theta); sind(obj.theta) cosd(obj.theta)];
            obj.P = obj.P+(R*[lt,0]')';
            obj.Vb = (R*[obj.V;0])';
        end
        
        function ballb(obj)
            if (obj.P(2)>=obj.L)
                obj.upperb();
            elseif (obj.P(2)<=-obj.L)
                obj.lowerb();
            end
        end
        
        function info = chance1(obj)
            UR = 0;
            lastball = obj.P(2);
            
            if (abs(obj.P(2)-obj.PAD_AGENT)>obj.PW)
                UR = -1;
                obj.roundflag = true;
                obj.SCORE(1) = obj.SCORE(1)+1;
                if (any(obj.SCORE==obj.endscore))
                    obj.totalflag = true;
                end
            else
                if obj.positive
                    UR = 1;
                end
                
                xt = obj.P(1)-obj.W+obj.B;
                lt = obj.V*xt/abs(obj.Vb(1));
                obj.P = [obj.W-obj.B,obj.P(2)-lt*sind(obj.theta)];
                obj.Vb(1) = -obj.Vb(1);
                
                if (obj.theta <= 0)
                    thr = randi([-obj.thrMAX, min(obj.thrMAX,89+obj.theta)]);
                    obj.theta = -180-obj.theta;
                else
                    thr = randi([max(-obj.thrMAX,-89+obj.theta), obj.thrMAX]);
                    obj.theta = 180-obj.theta;
                end
                
                obj.theta = obj.theta+thr;
                obj.theta = mod(obj.theta+180,360)-180;
                R = [cosd(obj.theta) -sind(obj.theta); sind(obj.theta) cosd(obj.theta)];
                obj.P = obj.P+(R*[lt,0]')';
                obj.Vb = (R*[obj.V;0])';
            end
            
            info = [UR,lastball,obj.totalflag];
        end
        
        function chance2(obj)
            if (abs(obj.P(2)-obj.PAD_OP)>obj.PW)
                obj.roundflag = true;
                obj.SCORE(2) = obj.SCORE(2)+1;
                if (any(obj.SCORE==obj.endscore))
                    obj.totalflag = true;
                end
            else
                xt = obj.B-obj.W-obj.P(1);
                lt = obj.V*xt/abs(obj.Vb(1));
                obj.P = [obj.B-obj.W,obj.P(2)-lt*sind(obj.theta)];
                obj.Vb(1) = -obj.Vb(1);

                if (obj.theta >= 0)
                    thr = randi([-obj.thrMAX, min(obj.thrMAX,-91+obj.theta)]);
                    obj.theta = 180-obj.theta;
                else
                    thr = randi([max(-obj.thrMAX,91+obj.theta), obj.thrMAX]);
                    obj.theta = -180-obj.theta;
                end

                obj.theta = obj.theta+thr;
                obj.theta = mod(obj.theta+180,360)-180;
                R = [cosd(obj.theta) -sind(obj.theta); sind(obj.theta) cosd(obj.theta)];
                obj.P = obj.P+(R*[lt,0]')';
                obj.Vb = (R*[obj.V;0])';
            end
        end
        
        function start(obj)            
            if (obj.totalflag)
                obj.totalflag = false;
                obj.SCORE = [0,0];
            end
            
            if (obj.roundflag)
                obj.roundflag = false;
            end
            
            obj.P = [0,0];
            obj.PAD_AGENT = 0;
            obj.PAD_OP = 0;
            obj.theta = randi([-obj.thMAX, obj.thMAX])+(180*randi([0,1]));
            obj.theta = mod(obj.theta+180,360)-180;    
            R = [cosd(obj.theta) -sind(obj.theta); sind(obj.theta) cosd(obj.theta)];
            obj.Vb = (R*[obj.V;0])';    
        end

        function [P,Vb,PAD] = goball(obj)
            if obj.totalflag || obj.roundflag
                obj.start();
            end
            
            obj.C = obj.C+1;
            obj.P = obj.P+obj.Vb;
            obj.ballb();
            if (abs(obj.P(1))>obj.W)||(abs(obj.P(2))>obj.L)||any(isnan(obj.P))
                obj.P = [0,0];
                obj.ErrN = obj.ErrN+1;
            end
                
            P = obj.P;
            Vb = obj.Vb;
            PAD = obj.PAD_AGENT;
            
            obj.theta = mod(obj.theta+180,360)-180;
            
            if (mod(obj.C,1E4)==0)
                timeinterval = toc; 
                pstring = [obj.nstring '-' num2str(obj.idx) '-' num2str(obj.C) obj.estring '- Time:' num2str(timeinterval,2)];
                disp(strjoin(pstring,''));
                
                tic;
            end
        end
        
        function info = gopad(obj,a1)
            info = [0,0,0];
            a2 = obj.champ();

            obj.PAD_AGENT = obj.padb(obj.PAD_AGENT,a1);
            obj.PAD_OP = obj.padb(obj.PAD_OP,a2);
            
            if (obj.P(1)>obj.W-obj.B)
                info = obj.chance1();
            elseif (obj.P(1)<obj.B-obj.W)
                obj.chance2();
            end
            
            if obj.totalflag
                info(3) = obj.totalflag;
                obj.endgame();
            end
        end
        
        function endgame(obj)
            diffscore = diff(obj.SCORE); 
            memo = [obj.idx,obj.C,diffscore];
            obj.board = [obj.board; memo];
        end
        
        function ACT_OP = champ(obj)
            if (obj.Vb(1)<=-1E-2)
                pred_op = obj.Vb(2)*(obj.B-obj.W-obj.P(1))/obj.Vb(1)+obj.P(2);
                pred_op = obj.L*sawtooth((pred_op+obj.L)*pi/(2*obj.L),0.5);
                pred_op = pred_op+normrnd(0,obj.distf);
                ACT_OP = 2*(pred_op>=obj.PAD_OP)-1;
            else
                pred_op = obj.P(2);
                ACT_OP = randi([-1 1]);
            end
        end
    end
end
