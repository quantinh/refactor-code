package crud::Controller::ActorController;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use DBI;
use strict;
use warnings;
use Data::Validator;

# Connect to database postgres
sub connect_db_pg {
  my $driver    = "Pg"; 
  my $database  = "learning-perl";
  my $dsn       = "DBI:Pg:dbname = learning-perl; host = localhost; port = 5432";
  my $userid    = "postgres";
  my $password  = "123456";
  my $dbh       = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;
  print "Connect database successfully\n";
  return $dbh;
}
# Action showData
sub show {
  my $self = shift;
  # use function connect database
  my $dbh = connect_db_pg();
  # string query to database
  my $sth = $dbh->prepare(qq(SELECT * FROM actor ORDER BY actor_id;));
  # Show error if false 
  my $rv = $sth->execute() or die $DBI::errstr;
  # show item put out
  ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n"; 
  # array of data
  my @rows;
  while (my $row = $sth->fetchrow_hashref) {
    push @rows, $row;
  }
  $sth->finish();
  $dbh->disconnect();
  $self->render(
    rows      => \@rows,
    template  => "myTemplates/list"
  );
  return;
}
# Action formAdd
sub fromAdd {
  my $self = shift;
  $self->render(
    template => 'myTemplates/add'
  );
}
# Action Add
sub add {
  my $self = shift;
  # use function connect database
  my $dbh = connect_db_pg();# kết nối tới cơ sở dữ liệu PostgreSQL
  # Code new ======================================

  # use function connect database
  # my $pg = Mojo::Pg->new('postgresql://postgres:123456@localhost/learning-perl');
  # Lấy dữ liệu từ form input
  my $first_name = $self->param('first_name');
  my $last_name = $self->param('last_name');

  # Sử dụng đối tượng validation trong Mojolicious để kiểm tra dữ liệu
  my $validation = $self->validation;
  $validation->required('first_name')->like(qr/^[a-zA-Z]+$/)->size(1, 50);
  $validation->required('last_name')->like(qr/^[a-zA-Z]+$/)->size(1, 50);

  # Kiểm tra có lỗi hay không
  if ($validation->has_error) {
    # Nếu có lỗi, hiển thị thông báo lỗi
    $self->render(
      text => 'có lỗi',
      # template => 'myTemplates/add',
      err_msg => $validation->error('first_name') || $validation->error('last_name')
    );
  } else {
    # Nếu không có lỗi, insert dữ liệu vào cơ sở dữ liệu
    # Thực hiện insert vào database
    my $query = qq(INSERT INTO actor (first_name, last_name, last_update) VALUES ('$first_name', '$last_name', NOW()););
    my $sth = $dbh->prepare($query);
    # Show error if false 
    my $rv = $sth->execute() or die $DBI::errstr;
    ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
    $sth->finish();
    $dbh->disconnect();
    # Lưu thông báo vào flash và chuyển hướng đến trang hiển thị danh sách bảng ghi
    $self->flash(success => 'Thêm mới actor thành công');
    return $self->redirect_to('/');
    # Hiển thị thông báo thành công
    # $self->render(
    #   text => 'đã thêm vào db',
    #   # template => 'myTemplates/list',
    #   err_msg => 'Data inserted successfully'
    # );
  }
  print "return abc,\n";
  # Hiển thị thông báo thành công
  # $self->render(
  #   template => 'myTemplates/list',
  #   success => $self->flash(success => 'Thêm mới actor thành công')
  # );
  # Code old
  # my $first_name = $self->param('first_name');
  # my $last_name = $self->param('last_name');
  # my $last_update = $self->param('last_update');

  # string query to database
  # my $query = qq(INSERT INTO actor (first_name, last_name, last_update) VALUES ('$first_name', '$last_name', NOW()););
  # my $sth = $dbh->prepare($query);
  # # Show error if false 
  # my $rv = $sth->execute() or die $DBI::errstr;
  # ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
  # $sth->finish();
  # $dbh->disconnect();

  # Lưu thông báo vào flash và chuyển hướng đến trang hiển thị danh sách bảng ghi
  $self->flash(success => 'Thêm mới actor thành công');
  return $self->redirect_to('/');
}
# Action Delete
sub delete {
  my $self = shift;
  # use function connect database
  my $dbh = connect_db_pg();
  my $id = $self->stash('id');
  my $sth = $dbh->prepare(qq(DELETE FROM actor WHERE actor_id = $id;));
  # string query to database
  my $rv = $sth->execute() or die $DBI::errstr;
  ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
  $sth->finish();
  $dbh->disconnect();
  # Lưu thông báo vào flash và chuyển hướng đến trang hiển thị danh sách bảng ghi
  $self->flash(success => 'Xóa thành công actor');
  return $self->redirect_to('/');
}
# Action formEdit
sub formUpdate {
  my $self = shift;
  # use function connect database
  my $dbh = connect_db_pg();
  my $id = $self->stash('id');
  # string query to database
  my $sth = $dbh->prepare(qq(SELECT * FROM actor WHERE actor_id = $id LIMIT 1));
  my $rv = $sth->execute() or die $DBI::errstr;
  my @rows;
  while (my $row = $sth->fetchrow_hashref) {
    push @rows, $row;
  }
  $self->render(
    rows => \@rows,
    template => 'myTemplates/update'
  );
}
# Action Edit
sub update {
  my $self = shift;
  # use function connect database
  my $dbh = connect_db_pg();
  my $id = $self->stash('id');
  my $first_name = $self->param('first_name');
  my $last_name = $self->param('last_name');
  my $sth = $dbh->prepare(qq(UPDATE actor SET first_name = '$first_name', last_name = '$last_name' WHERE actor_id = $id));
  my $rv = $sth->execute() or die $DBI::errstr;
  ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
  $sth->finish();
  $dbh->disconnect();
  # Lưu thông báo vào flash và chuyển hướng đến trang hiển thị danh sách bảng ghi
  $self->flash(success => 'Cập nhập thành công actor');
  $self->redirect_to('/');
}
1;
