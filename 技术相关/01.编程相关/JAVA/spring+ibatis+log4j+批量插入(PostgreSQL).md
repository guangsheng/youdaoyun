### 用到的类库
```
log4j-1.2.17.jar
postgresql-42.0.0.jar
oldlib/commons-logging-1.1.3.jar
oldlib/commons-pool-1.6.jar
oldlib/ibatis-2.3.4.726.jar
oldlib/spring-2.5.5.jar
oldlib/commons-dbcp-1.4.jar
```
### 程序目录结构
```
src
├─com
│  └─fisher
│      ├─bean
│      ├─dao
│      ├─idao
│      └─util
├─ibatis
└─spring
```

### 数据库表结构
```SQL
create database test;
create user test superuser;
alter user test password 'test';

\c test;
create table course(id int, coures_name varchar);

```

### 相关代码
####applicationContext.xml spring配置文件
```XML
<?xml version="1.0" encoding="UTF-8"?>  
<beans  
    xmlns="http://www.springframework.org/schema/beans"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.0.xsd">  

<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">  
  <property name="driverClassName"><value>org.postgresql.Driver</value></property>  
  <property name="username"><value>test</value></property>
  <property name="password"><value>test</value></property>
  <property name="url"><value>jdbc:postgresql://192.168.59.190:5432/test</value></property>
</bean>
  
<bean id="sqlMapClient" class="org.springframework.orm.ibatis.SqlMapClientFactoryBean">  
  <!-- 此处应注入ibatis配置文件，而非sqlMap文件，否则会出现“there is no statement.....异常” -->  
  <property name="configLocation"><value>ibatis/sqlMapConfig.xml</value></property>  
</bean>  
  
<bean id="CourseDAO" class="com.fisher.dao.CourseDAOImpl">
  <property name="dataSource"><ref bean="dataSource"/></property>  
  <property name="sqlMapClient"><ref bean="sqlMapClient"/></property>  
</bean>

</beans>  
```

#### sqlMapConfig.xml IBATIS总的配置文件
```XML
<?xml version="1.0" encoding="UTF-8"?>   
<!DOCTYPE sqlMapConfig
    PUBLIC "-//iBATIS.com//DTD SQL Map Config 2.0//EN"   
    "http://www.ibatis.com/dtd/sql-map-config-2.dtd">   

<sqlMapConfig>   
    <sqlMap resource="ibatis/ibatis.xml" />
</sqlMapConfig>  
```

#### ibatis.xml IBATIS详细配置文件，用于配置SQL
```XML
<?xml version="1.0" encoding="UTF-8" ?>  
<!DOCTYPE sqlMap PUBLIC "-//ibatis.apache.org//DTD SQL Map 2.0//EN" "http://ibatis.apache.org/dtd/sql-map-2.dtd" >  
<sqlMap >  
    <typeAlias type="com.fisher.bean.CourseBean" alias="CourseBean"/>  
    <resultMap id="CourseResult" class="CourseBean" >  
      <result column="id" property="id" jdbcType="VARCHAR" />  
      <result column="coures_name" property="coures_name" jdbcType="VARCHAR" />  
    </resultMap>  
    
    <select id="queryCourse" resultMap="CourseResult">  
        select id, coures_name
          from course
         where id = #id#
         limit #result_limit#
    </select> 
    
    <select id="queryAllCourse" resultMap="CourseResult">  
        select id, coures_name
          from course
         limit #result_limit#
    </select> 
    
    <insert id="saveCourse" parameterClass="CourseBean">  
        insert into course (id,coures_name) values (#id#,#coures_name#)
    </insert>  
     
    <delete id="deleteCourse" parameterClass="CourseBean">  
        delete from course where id = #id#  
    </delete>  
     
    <delete id="updateCourse" parameterClass="CourseBean">  
        update course set coures_name = #coures_name# where id = #id#  
    </delete>  
</sqlMap>  
```

#### BEAN
```java
package com.fisher.bean;

public class CourseBean {
	private int id;
	private String coures_name;
	private int result_limit;
	
	public int getResult_limit() {
		return result_limit;
	}
	public void setResult_limit(int result_limit) {
		this.result_limit = result_limit;
	}
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getCoures_name() {
		return coures_name;
	}
	public void setCoures_name(String coures_name) {
		this.coures_name = coures_name;
	}
	@Override
	public String toString() {
		return "Course id is "+this.getId()+", name is "+this.getCoures_name();
	}
}

```
#### 接口
```java
package com.fisher.idao;

import java.sql.SQLException;
import java.util.List;

import com.fisher.bean.CourseBean;

public interface ICourseDAO {
	public int saveCourse(CourseBean course) throws SQLException;
	public int deleteCourse(CourseBean course) throws SQLException;
	public int updateCourse(CourseBean course) throws SQLException;
	
	public List<CourseBean> queryCourse(CourseBean whereBean, int limitCount) 
			throws SQLException;
	
	public List<CourseBean> queryAllCourse(int limitCount) 
			throws SQLException;
	
	public int batchSaveCourse(List<CourseBean> beanList, int batchCount) throws SQLException;
}

```
#### 工具类
```java
package com.fisher.util;

import java.sql.SQLException;
import java.util.List;

import org.springframework.dao.DataAccessException;
import org.springframework.orm.ibatis.SqlMapClientCallback;
import org.springframework.orm.ibatis.support.SqlMapClientDaoSupport;

import com.ibatis.sqlmap.client.SqlMapExecutor; 

public class BaseDAOImpl extends SqlMapClientDaoSupport{

	protected int insert(final String statment, 
			final List<? extends Object> objList, 
			final int batchCount) throws DataAccessException {
		Object number = 
				this.getSqlMapClientTemplate().execute(new SqlMapClientCallback() {  
					public Object doInSqlMapClient(SqlMapExecutor executor) throws SQLException {  
						int insertNumber = 0;
						int batch = 0;
						executor.startBatch();
						for (Object obj : objList) {  
							executor.insert(statment, obj);  
							batch++;  
							if (batch == batchCount) {  
								insertNumber += executor.executeBatch();  
								batch = 0;
								executor.startBatch();
							}  
						}  
						insertNumber += executor.executeBatch();  
						return insertNumber;  
					}  
				});
		if (number instanceof Integer)
			return ((Integer) number).intValue();
		return 0;  
    }  
}

```
#### 接口实现
```java
package com.fisher.dao;

import java.sql.SQLException;
import java.util.List;

import com.fisher.bean.CourseBean;
import com.fisher.idao.ICourseDAO;
import com.fisher.util.BaseDAOImpl;

public class CourseDAOImpl extends BaseDAOImpl implements ICourseDAO{

	@Override
	public int saveCourse(CourseBean course) throws SQLException {
		Object number = super.getSqlMapClientTemplate().insert("saveCourse", course);
		
		if (number instanceof Integer)
			return ((Integer) number).intValue();
		return 0;
	}

	@Override
	public int deleteCourse(CourseBean course) throws SQLException {
		Object number = super.getSqlMapClientTemplate().delete("deleteCourse", course);
		
		if (number instanceof Integer)
			return ((Integer) number).intValue();
		return 0;
	}

	@Override
	public int updateCourse(CourseBean course) throws SQLException {
		Object number = super.getSqlMapClientTemplate().update("updateCourse", course);
		
		if (number instanceof Integer)
			return ((Integer) number).intValue();
		return 0;
	}

	@Override
	public List<CourseBean> queryCourse(CourseBean whereBean, int limitCount) throws SQLException {
		if (limitCount <= 0)
			limitCount = Integer.MAX_VALUE;
		whereBean.setResult_limit(limitCount);
		return super.getSqlMapClientTemplate().queryForList("queryCourse", whereBean);
	}

	@Override
	public List<CourseBean> queryAllCourse(int limitCount) throws SQLException {
		CourseBean whereBean = new CourseBean();
		if (limitCount <= 0)
			limitCount = Integer.MAX_VALUE;
		whereBean.setResult_limit(limitCount);
		return super.getSqlMapClientTemplate().queryForList("queryAllCourse", whereBean);
	}

	@Override
	public int batchSaveCourse(List<CourseBean> beanList, int batchCount) throws SQLException {
		return super.insert("saveCourse", beanList, batchCount);
	}
}

```
#### 测试程序
```java
package com.fisher;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import com.fisher.bean.CourseBean;
import com.fisher.dao.CourseDAOImpl;

public class TestMain {

	private static CourseBean getCourse(final int id){
		CourseBean bean = new CourseBean();
		bean.setId(id);
		bean.setCoures_name("Name"+id);
		return bean;
	}
	
	private static void printAllCourse(CourseDAOImpl courseDAO) throws SQLException
	{
		
		List<CourseBean> courseList = courseDAO.queryAllCourse(0);
		for(CourseBean cbean : courseList)
			System.out.println(cbean);
		
		return;
	}
	
	public static void main(String[] args) {
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");//设置日期格式
		ApplicationContext context=new ClassPathXmlApplicationContext("spring/applicationContext.xml");  
        CourseDAOImpl courseDAO = (CourseDAOImpl)context.getBean("CourseDAO");
        
        CourseBean course = getCourse(1);
        System.out.println("Begin:"+df.format(new Date()));
        try {
			courseDAO.saveCourse(course);
			course.setId(1);
			
			course.setId(2);
			course.setCoures_name("Chinese");
			courseDAO.saveCourse(course);
			course.setId(3);
			course.setCoures_name("English");
			courseDAO.saveCourse(course);
			course.setId(4);
			course.setCoures_name("Biology");
			courseDAO.saveCourse(course);
			course.setId(5);
			course.setCoures_name("math");
			courseDAO.saveCourse(course);
			
			System.out.println("After save course:");
			printAllCourse(courseDAO);
			
			course.setId(1);
			courseDAO.deleteCourse(course);
			System.out.println("After delete course 1");
			printAllCourse(courseDAO);
			
			course.setId(5);
			course.setCoures_name("Math");
			courseDAO.updateCourse(course);
			System.out.println("After update course 5");
			printAllCourse(courseDAO);
			
			ArrayList<CourseBean> beanList = new ArrayList<CourseBean>();
			for(int loop_i = 10; loop_i <= 50; loop_i++){
				CourseBean bean = getCourse(loop_i);
				beanList.add(bean);
			}
			int insertNumber = courseDAO.batchSaveCourse(beanList, 5);
			System.out.println("After batch insert("+insertNumber+"):");
			printAllCourse(courseDAO);
			
		} catch (SQLException e) {
			e.printStackTrace();
		}
        System.out.println("End:"+df.format(new Date()));
	}

}

```