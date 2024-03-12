function D = data_transform(M, data) % HTM a rigid body function
    D = zeros(size(data));
    for i = 1:size(data,1)
       vec = M * [data(i,:),1]';
       D(i,:) = vec(1:3);
    end
end