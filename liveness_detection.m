RAW_PATH = '/home/zhoujie/liveness detection/raw文件/non-face/';
PLANE_OR_NOT = 0.1;
ITER = 10000;

file =dir([RAW_PATH ,'*.raw']);

for num=1:length(file)
f1 = fopen([RAW_PATH,file(num).name], 'r');
rawname = file(num).name;
txtname = strrep(rawname,'.raw','.txt');
[par1,par2,par3,par4] = textread([RAW_PATH,txtname],'%d%d%d%d',1);
data0 = fread(f1, 'uint16');
fclose(f1);
img1 = reshape(data0, 400, 345);
dep_img = img1';
% dep_img(find(dep_img > 600))= 0;
% figure(1),imshow(dep_img,[400,580]); 
face = dep_img(par2 :par2 +par4,par1 :par1 + par3); 
% figure(2),imshow(face,[400,580]); 
%%%三维平面拟合
[X Y]=meshgrid(1:size(face,2),1:size(face,1));
zz=face(:);xx=X(:);yy=Y(:);
data=[xx';yy';zz'];
id = data(3,:) == 0;
data(:,id) = [];
iter = ITER; 
%%% 绘制数据点
 number = size(data,2); % 总点数
%  bestParameter1=0; bestParameter2=0; bestParameter3=0; % 最佳匹配的参数
 sigma = 1;
 pretotal=0;     %符合拟合模型的数据的个数
for i=1:iter
 %%% 随机选择三个点
     idx = randperm(number,3); 
     sample = data(:,idx); 
     %%%拟合直线方程 z=ax+by+c
     plane = zeros(1,3);
     x = sample(1,:);
     y = sample(2,:);
     z = sample(3,:);
     a = ((z(1)-z(2))*(y(1)-y(3)) - (z(1)-z(3))*(y(1)-y(2)))/((x(1)-x(2))*(y(1)-y(3)) - (x(1)-x(3))*(y(1)-y(2)));
     b = ((z(1) - z(3)) - a * (x(1) - x(3)))/(y(1)-y(3));
     c = z(1) - a * x(1) - b * y(1);
     plane = [a b -1 c];
     mask=abs(plane*[data; ones(1,size(data,2))]);    %求每个数据到拟合平面的距离
     total=sum(mask<sigma);              %计算数据距离平面小于一定阈值的数据的个数
     if total>pretotal            %找到符合拟合平面数据最多的拟合平面
         pretotal=total;
%          bestplane=plane;          %找到最好的拟合平面
    end  
end

pretotal_ary = pretotal/number;
% potable(num) = pretotal_ary;
if(pretotal_ary>PLANE_OR_NOT)
    descrip = '不是人脸';
else
descrip = '是人脸'; 
end
disp(['pretotal=',num2str(pretotal),',','_ary=',num2str(pretotal_ary),',',rawname,descrip]);
end

